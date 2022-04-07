extends Object
class_name Parser

# this code base on code from:
# https://github.com/nathanhoad/godot_dialogue_manager 

# Parser for RenScript
# language is based on Ren'Py and GDScript

# _init dialogue is used for code outside other dialogues
const init_dialogue_name = "_init"

# tokens for RenScript
# tokens in this language can be extended by the other addons

# tokens
var Tokens := {
	TOKEN_FUNCTION = "^{VALID_VARIABLE}\\(",
	TOKEN_DICTIONARY_REFERENCE = "^{VALID_VARIABLE}\\[",
	TOKEN_PARENS_OPEN = "^\\(",
	TOKEN_PARENS_CLOSE = "^\\)",
	TOKEN_BRACKET_OPEN = "^\\[",
	TOKEN_BRACKET_CLOSE = "^\\]",
	TOKEN_BRACE_OPEN = "^\\{",
	TOKEN_BRACE_CLOSE = "^\\}",
	TOKEN_COLON = "^:",
	TOKEN_COMPARISON = "^(==|<=|>=|<|>|!=|in )",
	TOKEN_NUMBER = "^\\-?\\d+(\\.\\d+)?",
	TOKEN_OPERATOR = "^(\\+|-|\\*|/)",
	TOKEN_ASSIGNMENT = "^(=|\\+=|\\-=|\\*=|\\/=|\\%=|\\^=|\\|=|\\&=)",
	TOKEN_COMMA = "^,",
	TOKEN_BOOL = "^(true|false)",
	TOKEN_AND_OR = "^(and|or)( |$)",
	TOKEN_STRING = "^\".*?\"",
	TOKEN_VARIABLE = "^[a-zA-Z_][a-zA-Z_0-9]+",
	TOKEN_TAB = "^\\t",
	TOKEN_NUMERIC = "-?[1-9][0-9.]*"
}

# Regex for RenScript
# Regex in this language can be extended by the other addons

var Regex := {
	VALID_VARIABLE = "[a-zA-Z_][a-zA-Z_0-9]+",
	# TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
	CONDITION = "(if|elif) (?<condition>.*)",
	STRING = "\".*\"",
	MULTILINE_STRING = "\"\"\"(?<string>.*)\"\"\"",
	COMMENT = "^#.*",

	# for setting Rakugo variables
	SET_VARIABLE = "^(?<variable>{VALID_VARIABLE}) = (?<value>{TOKEN_NUMERIC})",

	# $ some_gd_script_code
	IN_LINE_GDSCRIPT = "^\\$.*",
	# gdscript:
	GDSCRIPT_BLOCK = "^gdscript:",
	
	# dialogue Regex
	DIALOGUE = "^(?<label>{VALID_VARIABLE}):$",
	# character tag = "character_name"
	CHARACTER_DEF = "^character (?<tag>{VALID_VARIABLE}) \"(?<name>.*)\"$",
	# character_tag? say STRING|MULTILINE_STRING
	SAY = "^((?<character_tag>{VALID_VARIABLE}) )?(?<text>{STRING})$",
	# var_name = ask "please enter text" 
	ASK = "^(?<variable>{VALID_VARIABLE}) = ((?<character_tag>{VALID_VARIABLE}) )?(?<question>{STRING}) \\? (?<default_answer>{STRING})$",
	# menu menu_name? :
	#   choice1 "label":
	#     say "text"
	MENU = "^menu( (?<label>{VALID_VARIABLE}))?:$",
	#   choice1 "label":
	CHOICE = "^(?<text>{STRING})( > (?<label>{VALID_VARIABLE}))?$",
	JUMP = "^jump (?<label>{VALID_VARIABLE})$",
}

var regex_cache := {}

var thread:Thread
var step_semaphore:Semaphore

var stop_thread := false

enum State {Normal = 0, Menu, Jump}

var state = State.Normal

var menu_jump_index:int

var parse_array:Array

#contain label : index
var labels:Dictionary

func _init():
	Rakugo.connect("menu_return", self, "_on_menu_return")
	Rakugo.connect("ask_return", self, "_on_ask_return")
	
	for t in Tokens.keys():
		Tokens[t] = Tokens[t].format(Regex)
		# prints(t, Tokens[t])
		
		var reg := RegEx.new()
		if reg.compile(Tokens[t]) != OK:
			prints("Parser", "_init", "failed", t)
		
		regex_cache[t] = reg

	for r in Regex.keys():
		Regex[r] = Regex[r].format(Tokens)
		
		Regex[r] = Regex[r].format(Regex)
		prints(r, Regex[r])

		var reg := RegEx.new()
		if reg.compile(Regex[r]) != OK:
			prints("Parser", "_init", "failed", r)
		
		regex_cache[r] = reg

func parse_script(file_name:String) -> int:
	thread = Thread.new()
	
	step_semaphore = Semaphore.new()
	
	return thread.start(self, "do_parse_and_execute", file_name)

func close():
	if thread:
		stop_thread = true
		
		step_semaphore.post()
		
		thread.wait_to_finish()

func count_indent(s:String) -> int:
	var ret := 0
	
	if s[0] == '	':
		for i in s.length():
			var c = s[i]
		
			if c == '	':
				ret += 1
			else:
				break
	
	return ret

func remove_double_quotes(s:String) -> String:
	return s.substr(1, s.length()-2)

func do_parse_script(file_name:String):
	# var known_translations = {}
	# var errors: Array = []
	# var parent_stack: Array = []
	
	#TODO parse and save in dictionary first and read after
	
	var file = File.new()
	
	if file.open(file_name, File.READ) != OK:
		prints("Parser", "can't open file : " + file_name)
		return
	
	var indent_count:int
	
	var menu_choices
	var menu_jumps:Dictionary
	
	var jump_label:String
	
	var current_menu_result
	
	while !stop_thread:
		if state == State.Menu and file.eof_reached():
			state = State.Normal
				
#			prints("Parser", "parse_script", "mod Normal")
			
			if !menu_choices.empty():
				parse_array.push_back(["MENU", current_menu_result, menu_choices])
			else:
				break
		elif file.eof_reached():
			break
		
		var line = file.get_line()

		if line.empty():
			continue

		#erase tabulations
		# TODO handle indentation levels
		indent_count = count_indent(line)
		
		line = line.lstrip('	')

		var result:RegExMatch

		if state == State.Menu and indent_count == 0:
			state = State.Normal
				
#			prints("Parser", "parse_script", "mod Normal")
			
			if !menu_choices.empty():
				parse_array.push_back(["MENU", current_menu_result, menu_choices])

		match(state):
			State.Normal:
				result = regex_cache["GDSCRIPT_BLOCK"].search(line)
				if result:
					prints("Parser", "parse_script", "GDSCRIPT_BLOCK")
					#current_dialogue.append(line)
					continue

				result = regex_cache["IN_LINE_GDSCRIPT"].search(line)
				if result:
					prints("Parser", "parse_script", "IN_LINE_GDSCRIPT")
					#current_dialogue.append(line)
					continue

				result = regex_cache["CHARACTER_DEF"].search(line)
				if result:
#					prints("Parser", "parse_script", "CHARACTER_DEF")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))

					parse_array.push_back(["CHARACTER_DEF", result])

					continue

				result = regex_cache["SAY"].search(line)
				if result:
#					prints("Parser", "parse_script", "SAY")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key)) 

					parse_array.push_back(["SAY", result])

					continue

				result = regex_cache["ASK"].search(line)
				if result:
#					prints("Parser", "parse_script", "ASK")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))
					
					parse_array.push_back(["ASK", result])

					continue

				result = regex_cache["MENU"].search(line)
				if result:
#					prints("Parser", "parse_script", "MENU")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))

					current_menu_result = result
					
					menu_choices = []
					
					state = State.Menu

					labels[result.get_string("label")] = parse_array.size() - 1

#					prints("Parser", "parse_script", "mode Menu")
					continue
				
				result = regex_cache["DIALOGUE"].search(line)
				if result:
#					prints("Parser", "parse_script", "DIALOGUE")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))

					var dialogue_label = result.get_string("label")
				
					labels[dialogue_label] = parse_array.size() - 1
						
					continue
				
				result = regex_cache["JUMP"].search(line)
				if result:
#					prints("Parser", "parse_script", "JUMP")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))

					parse_array.push_back(["JUMP", result])

					continue
			
			State.Menu:
				result = regex_cache["CHOICE"].search(line)
				if result:
#					prints("Parser", "parse_script", "CHOICE")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))
						
					menu_choices.push_back(result)
					
					continue

	file.close()
	
	prints("Parser", "do_parse_script", "end")

func do_execute_jump(jump_label:String) -> int:
	var index := -1
	if labels.has(jump_label):
		index = labels[jump_label]
		
		if index >= parse_array.size():
			printerr("Parser, do_execute_script, JUMP, index out of range")
			index = -1
	else:
		printerr("Parser, do_execute_script, JUMP, unknow label")
		
	return index

func do_execute_script():
	var index := 0
	
	while !stop_thread and index < parse_array.size():
		var line = parse_array[index]
		
		var result = line[1]
		
		match(line[0]):
			"JUMP":
				index = do_execute_jump(result.get_string("label"))
				
				if index == -1:
					break
			
			"SAY":
				Rakugo.say(result.get_string("character_tag"), remove_double_quotes(result.get_string("text")))

				Rakugo.step()

				step_semaphore.wait()
				
			"CHARACTER_DEF":
				Rakugo.define_character(result.get_string("name"), result.get_string("tag"))
				
			"ASK":
				Rakugo.ask(result.get_string("variable"), result.get_string("character_tag"), remove_double_quotes(result.get_string("question")), remove_double_quotes(result.get_string("default_answer")))

				step_semaphore.wait()
				
			"MENU":
				var menu_choices:PoolStringArray
				
				var menu_jumps:Dictionary
				
				for i in line[2].size():
					var menu_choice_result = line[2][i]
					
					menu_choices.push_back(remove_double_quotes(menu_choice_result.get_string("text")))
					
					var label = menu_choice_result.get_string("label")
					if !label.empty():
						menu_jumps[i] = label
				
				Rakugo.menu(menu_choices)

				step_semaphore.wait()
				
				if menu_jumps.has(menu_jump_index):
					var jump_label = menu_jumps[menu_jump_index]

					index = do_execute_jump(jump_label)
				
					if index == -1:
						break
						
					prints("Parser", "parse_script", "menu_jump", jump_label)
		
		index += 1
		
	prints("Parser", "do_execute_script", "end")

func do_parse_and_execute(file_name:String):
	do_parse_script(file_name)
	
	do_execute_script()

func _on_menu_return(index:int):
	menu_jump_index = index
	
	step_semaphore.post()

func _on_ask_return(result):
	step_semaphore.post()
