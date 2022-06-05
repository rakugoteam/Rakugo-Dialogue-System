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

var Regex := {
	VALID_VARIABLE = "[a-zA-Z_][a-zA-Z_0-9]+",
	NUMERIC = "-?[1-9][0-9.]*",
	STRING = "\".*\"",
#	MULTILINE_STRING = "\"\"\"(?<string>.*)\"\"\"",
}

# Regex for RenScript
# Regex in this language can be extended by the other addons
# Order is matter !
var parser_regex :={
	# dialogue label_name:
	DIALOGUE = "^(?<label>{VALID_VARIABLE}):$",
	# character tag = "character_name"
	CHARACTER_DEF = "^character (?<tag>{VALID_VARIABLE}) \"(?<name>.*)\"$",
	# character_tag? "say"
	SAY = "^((?<character_tag>{VALID_VARIABLE}) )?(?<text>{STRING})$",
	# var_name = character_tag? "please enter text" 
	ASK = "^(?<variable>{VALID_VARIABLE}) = ((?<character_tag>{VALID_VARIABLE}) )?(?<question>{STRING}) \\? (?<default_answer>{STRING})$",
	# menu label_name?:
	MENU = "^menu( (?<label>{VALID_VARIABLE}))?:$",
	# "like regex" (> label_name)?
	CHOICE = "^(?<text>{STRING})( > (?<label>{VALID_VARIABLE}))?$",
	# jump label
	JUMP = "^jump (?<label>{VALID_VARIABLE})( if (?<expression>.+))?$",
	# for setting Rakugo variables
	SET_VARIABLE = "(?<lvar_name>{VALID_VARIABLE}) = ((?<text>{STRING})|(?<number>{NUMERIC})|(?<rvar_name>{VALID_VARIABLE}))",
	# $ some_gd_script_code
#	IN_LINE_GDSCRIPT = "^\\$.*",
	# gdscript:
#	GDSCRIPT_BLOCK = "^gdscript:",
#	COMMENT = "^#.*",
#	TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
#	CONDITION = "(if|elif) (?<condition>.*)",
}

var other_regex :={
	ALL_VARIABLES = "((?<char_tag>{VALID_VARIABLE})\\.)?(?<var_name>{VALID_VARIABLE})",
	CHARACTER_VARIABLES = "\\<(?<char_tag>{VALID_VARIABLE})\\.(?<var_name>{VALID_VARIABLE})\\>",
	VARIABLES = "\\<(?<var_name>{VALID_VARIABLE})\\>",
}

var regex_cache := {}

var other_cache := {}

var thread:Thread
var step_semaphore:Semaphore

var stop_thread := false

enum State {Normal = 0, Menu, Jump}

var state = State.Normal

var menu_jump_index:int

var parse_array:Array

#contain label : index
var labels:Dictionary

func add_regex(key:String, regex:String, cache:Dictionary, error:String):
	regex = regex.format(Regex)
	
	var reg := RegEx.new()
	if reg.compile(regex) != OK:
		push_error(error)
		
	cache[key] = reg
	
func add_regex_at_runtime(key:String, regex:String):
	add_regex(key, regex, regex_cache, "Parser, add_regex_at_runtime, failed " + key)

func _init():
	Rakugo.connect("menu_return", self, "_on_menu_return")
	Rakugo.connect("ask_return", self, "_on_ask_return")
	
#	for t in Tokens.keys():
#		Tokens[t] = Tokens[t].format(Regex)
#		# prints(t, Tokens[t])
#
#		var reg := RegEx.new()
#		if reg.compile(Tokens[t]) != OK:
#			push_error("Parser, _init, failed " + t)
#
#		regex_cache[t] = reg

	for key in parser_regex:
		add_regex(key, parser_regex[key], regex_cache, "Parser, _init, failed " + key)
		
	for key in other_regex:
		add_regex(key, other_regex[key], other_cache, "Parser, _init, failed " + key)

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
	var file = File.new()
	
	if file.open(file_name, File.READ) != OK:
		prints("Parser", "can't open file : " + file_name)
		return
	
	var lines = file.get_as_text().split("\n", false)
	
	file.close()
	
	var indent_count:int
	
	var menu_choices
	
	var current_menu_result
	
	for i in lines.size():
		var line = lines[i]
		
		# TODO handle indentation levels
		indent_count = count_indent(line)
	
		#erase tabulations
		line = line.lstrip('	')
	
		if state == State.Menu and indent_count == 0:
			state = State.Normal
				
#			prints("Parser", "parse_script", "mod Normal")
			
			if !menu_choices.empty():
				parse_array.push_back(["MENU", current_menu_result, menu_choices])
	
		match(state):
			State.Normal:
				for key in regex_cache:
					var result = regex_cache[key].search(line)
					
					if result:
						match(key):
							"MENU":
								current_menu_result = result
					
								menu_choices = []
								
								state = State.Menu

								labels[result.get_string("label")] = parse_array.size()
								
							"DIALOGUE":
								var dialogue_label = result.get_string("label")
				
								labels[dialogue_label] = parse_array.size()
							
							"JUMP":
								var str_expression = result.get_string("expression")
								
								if str_expression.empty():
									parse_array.push_back([key, result])
									break
									
								var sub_results = other_cache["ALL_VARIABLES"].search_all(str_expression)
								
								var vars = []
								
								for sub_result in sub_results:
									var sub_result_str = sub_result.strings[0]
									
									if !vars.has(sub_result_str):
										vars.push_back(sub_result_str)
								
								var expression = Expression.new()
								
								if expression.parse(str_expression, vars) != OK:
									push_error("Parser: Error on line: " + str(i) + ", " + expression.get_error_text())
									break
									
								parse_array.push_back([key, result, expression, vars])
							
							_:
								parse_array.push_back([key, result])
						break
			State.Menu:
				var result = regex_cache["CHOICE"].search(line)
				if result:
#					prints("Parser", "parse_script", "CHOICE")
#
#					for key in result.names:
#						prints(" ", key, result.get_string(key))
						
					menu_choices.push_back(result)
					
					continue
					
		if state == State.Menu and i == lines.size() - 1 and !menu_choices.empty():
			parse_array.push_back(["MENU", current_menu_result, menu_choices])
	
	prints("Parser", "do_parse_script", "end")

func do_execute_jump(jump_label:String) -> int:
	var index := -1
	if labels.has(jump_label):
		index = labels[jump_label]
		
		if index >= parse_array.size():
			push_error("Parser, do_execute_script, JUMP, index out of range")
			index = -1
	else:
		push_error("Parser, do_execute_script, JUMP, unknow label")
		
	return index

func do_execute_script():
	var index := 0
	
	while !stop_thread and index < parse_array.size():
		var line:Array = parse_array[index]
		
		var result = line[1]
		
		match(line[0]):
			"JUMP":
				var can_jump = false
				
				if line.size() > 2:
					var values = []
					
					for var_name in line[3]:
						var var_ = Rakugo.get_variable(var_name)
						
						if !var_:
							push_error("Execute: Error on line: " + str(index))
							return FAILED
						
						values.push_back(var_)
					
					can_jump = line[2].execute(values)
				else:
					can_jump = true
				
				if can_jump:
					index = do_execute_jump(result.get_string("label")) - 1
				
				if index == -2:
					break
			
			"SAY":
				var text = remove_double_quotes(result.get_string("text"))
				
				var sub_results = other_cache["CHARACTER_VARIABLES"].search_all(text)
				
				for sub_result in sub_results:
					var var_ = Rakugo.get_character_variable(
						sub_result.get_string("char_tag"),
						sub_result.get_string("var_name")
					)
						
					if var_:
						text = text.replace(sub_result.strings[0], var_)
				
				sub_results = other_cache["VARIABLES"].search_all(text)
				
				for sub_result in sub_results:
					var var_ = Rakugo.get_variable(sub_result.get_string("var_name"))
					
					if var_:
						text = text.replace(sub_result.strings[0], var_)
				
				Rakugo.say(result.get_string("character_tag"), text)

				Rakugo.step()

				step_semaphore.wait()
				
			"CHARACTER_DEF":
				Rakugo.define_character(result.get_string("tag"), result.get_string("name"))
				
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

					index = do_execute_jump(jump_label) - 1
				
					if index == -2:
						break
						
					prints("Parser", "do_execute_script", "menu_jump", jump_label)
		
			"SET_VARIABLE":
				var rvar_name = result.get_string("rvar_name")
				var text = result.get_string("text")
				
				var value
				
				if !rvar_name.empty():
					if Rakugo.has_variable(rvar_name):
						value = Rakugo.get_variable(rvar_name)
					else:
						push_error("Parser::do_execute_script::SET_VARIABLE, variable " + rvar_name + " does not exist !")
						break
				elif !text.empty():
					value = remove_double_quotes(text)
				else:
					value = result.get_string("number")
				
				Rakugo.set_variable(result.get_string("lvar_name"), value)
			_:
				Rakugo.emit_signal("parser_unhandled_regex", line[0], result)
		
		index += 1
		
	prints("Parser", "do_execute_script", "end ")

func do_parse_and_execute(file_name:String):
	do_parse_script(file_name)
	
	do_execute_script()

func _on_menu_return(index:int):
	menu_jump_index = index
	
	step_semaphore.post()

func _on_ask_return(result):
	step_semaphore.post()
