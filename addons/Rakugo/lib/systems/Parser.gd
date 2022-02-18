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
	TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
	CONDITION = "(if|elif) (?<condition>.*)",
	STRING = "\".*\"",
	MULTILINE_STRING = "\"\"\"(?<string>.*)\"\"\"",
	COMMENT = "^#.*",

	# for setting Rakugo variables
	SET_VARIABLE = "^(?<variable>{VALID_VARIABLE}) = (?<value>{TOKEN_NUMERIC})$",

	# $ some_gd_script_code
	IN_LINE_GDSCRIPT = "^\\$.*",
	# gdscript:
	GDSCRIPT_BLOCK = "^gdscript:",
	
	# dialogue Regex
	DIALOGUE = "^(?<dialogue_name>{VALID_VARIABLE}):",
	# character tag = "character_name"
	CHARACTER_DEF = "^character (?<tag>{VALID_VARIABLE}) \"(?<name>.*)\"",
	# character_tag? say STRING|MULTILINE_STRING
	SAY = "^((?<character_tag>{VALID_VARIABLE}) )?(?<text>{STRING})$",
	# var_name = ask "please enter text" 
	ASK = "^(?<variable>{VALID_VARIABLE}) = ((?<character_tag>{VALID_VARIABLE}) )?(?<question>{STRING}) \\? (?<default_answer>{STRING})$",
	# menu menu_name? :
	#   choice1 "label":
	#     say "text"
	MENU = "^menu( (?<menu_name>{VALID_VARIABLE}))?:$",
	#   choice1 "label":
	CHOICE = "^(?<text>{STRING})( > (?<label>{VALID_VARIABLE}))?$",
	JUMP = "jump (?<jump_to_title>.*)",
}

var regex_cache := {}

var thread:Thread
var step_semaphore:Semaphore

var stop_thread := false

enum State {Normal = 0, Menu}

var state = State.Normal

var menu_jump_index:int

func _init():
	Rakugo.connect("menu_return", self, "_on_menu_return")
	
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
		# prints(r, Regex[r])

		var reg := RegEx.new()
		if reg.compile(Regex[r]) != OK:
			prints("Parser", "_init", "failed", r)
		
		regex_cache[r] = reg

func parse_script(file_name:String) -> int:
	thread = Thread.new()
	
	step_semaphore = Semaphore.new()
	
	return thread.start(self, "do_parse_script", file_name)

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

func do_parse_script(file_name:String):
	# var known_translations = {}
	# var errors: Array = []
	# var parent_stack: Array = []
	
	var file = File.new()
	
	if file.open(file_name, File.READ) != OK:
		prints("Parser", "can't open file : " + file_name)
		return
	
	var indent_count:int
	
	var menu_choices:PoolStringArray
	var menu_jumps:Dictionary
	
	while !stop_thread and !file.eof_reached():
		var line = file.get_line()

		if line.empty():
			continue

		#erase tabulations
		#todo handle indentation levels
		indent_count = count_indent(line)
		
		line = line.lstrip('	')

		var result:RegExMatch

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
					prints("Parser", "parse_script", "CHARACTER_DEF")

					for key in result.names:
						prints(" ", key, result.get_string(key))

					Rakugo.define_character(result.get_string("name"), result.get_string("tag"))
					continue

				result = regex_cache["SAY"].search(line)
				if result:
					prints("Parser", "parse_script", "SAY")

					for key in result.names:
						prints(" ", key, result.get_string(key))

					Rakugo.say(result.get_string("character_tag"), result.get_string("string"))
					
					Rakugo.step()
					
					step_semaphore.wait()
					continue

				result = regex_cache["ASK"].search(line)
				if result:
					prints("Parser", "parse_script", "ASK")
					
					for key in result.names:
						prints(" ", key, result.get_string(key))
						
					Rakugo.ask(result.get_string("variable"), result.get_string("character_tag"), result.get_string("question"), result.get_string("default_answer"))

					step_semaphore.wait()
					
					
					continue

				result = regex_cache["MENU"].search(line)
				if result:
					prints("Parser", "parse_script", "MENU")
					
					for key in result.names:
						prints(" ", key, result.get_string(key))
				
					state = State.Menu
					
					menu_choices.resize(0)
					
					prints("Parser", "parse_script", "mod Menu")
					continue
			
			State.Menu:
				if indent_count == 0:
					state = State.Normal
				
					prints("Parser", "parse_script", "mod Normal")
					
					if !menu_choices.empty():
						Rakugo.menu(menu_choices)
						
						step_semaphore.wait()
						
						if menu_jumps.has(menu_jump_index):
							prints("Parser", "parse_script", "menu_jump", menu_jumps[menu_jump_index])
					continue
					
				result = regex_cache["CHOICE"].search(line)
				if result:
					prints("Parser", "parse_script", "CHOICE")
					
					for key in result.names:
						prints(" ", key, result.get_string(key))
					
					var label = result.get_string("label")
					if !label.empty():
						menu_jumps[menu_choices.size()] = label
				
					menu_choices.push_back(result.get_string("text"))
					continue

#		result = regex_cache["DIALOGUE"].search(line)
#		if result:
#			prints("Parser", "parse_script", "DIALOGUE")
#			var dialogue_name = result.get_string("dialogue_name")
#
#			if !dialogues.has(dialogue_name):
#				dialogues[dialogue_name] = []
#
#			current_dialogue = dialogues[dialogue_name]
#			continue

	file.close()
	
	prints("Parser", "do_parse_script", "end")

func _on_menu_return(index:int):
	menu_jump_index = index
	
	step_semaphore.post()

func parse_dialogue(lines:PoolStringArray) -> Array:
	var dialogue := []
	var current_menu := {}
	var current_choice := []
	var in_choice := false

	for l in lines:
		var result = regex_cache["CHARACTER_DEF"].search(l)
		if result:
			var character_tag = result.get_string("tag")
			var character_name = result.get_string("character_name")
			
			var character: = {
				"type": "character",
				"tag": character_tag,
				"name": character_name,
			}

			dialogue.append(character)
			
			continue

		result = regex_cache["SAY"].search(l)
		if result:
			var character_tag = result.get_string("character_tag")
			var text = result.get_string("text")

			var say: = {
				"type": "say",
				"character_tag": character_tag,
				"text": text,
			}

			if in_choice:
				current_choice.append(say)
			else:
				dialogue.append(say)
			
			continue

		result = regex_cache["ASK"].search(l)
		if result:
			var var_name = result.get_string("var_name")
			var assignment_type = result.get_string("assignment_type")
			var text = result.get_string("text")

			var ask: = {
				"type": "ask",
				"var_name": var_name,
				"assignment_type": assignment_type,
				"text": text,
			}

			if in_choice:
				current_choice.append(ask)
			else:
				dialogue.append(ask)

			continue

		result = regex_cache["MENU"].search(l)
		if result:
			var menu_name = result.get_string("menu_name")
			
			var menu: = {
				"type": "menu",
				"menu_name": menu_name,
				"choices": {}
			}

			current_menu = menu["choices"]
			dialogue.append(menu)

			continue

		result = regex_cache["CHOICE"].search(l)
		if result:
			var choice = result.get_string("choice")
			var label = result.get_string("label")
			
			var _choice := {
				"choice": choice,
				"label": label,
				"sub_dialogue": []
			}

			current_choice = choice["sub_dialogue"]
			current_menu[choice] = _choice
			in_choice = true

			continue

		result = regex_cache["JUMP"].search(l)
		if result:
			var jump_to_title = result.get_string("jump_to_title")
			
			var jump: = {
				"type": "jump",
				"jump_to_title": jump_to_title,
			}

			if in_choice:
				current_choice.append(jump)
			else:
				dialogue.append(jump)

			continue

		
	

	return dialogue
