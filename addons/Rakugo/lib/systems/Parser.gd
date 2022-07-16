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
	TOKEN_FUNCTION = "^{NAME}\\(",
	TOKEN_DICTIONARY_REFERENCE = "^{NAME}\\[",
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
	NAME = "[a-zA-Z_][a-zA-Z_0-9]+",
	NUMERIC = "-?[1-9][0-9.]*",
	STRING = "\".*\"",
	VARIABLE = "((?<char_tag>{NAME})\\.)?(?<var_name>{NAME})",
#	MULTILINE_STRING = "\"\"\"(?<string>.*)\"\"\"",
}

# Regex for RenScript
# Regex in this language can be extended by the other addons
# Order is matter !
var parser_regex :={
	# dialogue label_name:
	DIALOGUE = "^(?<label>{NAME}):$",
	# character tag = "character_name"
	CHARACTER_DEF = "^character (?<tag>{NAME}) \"(?<name>.*)\"$",
	# character_tag? "say"
	SAY = "^((?<character_tag>{NAME}) )?(?<text>{STRING})$",
	# var_name = character_tag? "please enter text" 
	ASK = "^(?<variable>{VARIABLE}) = ((?<character_tag>{NAME}) )?(?<question>{STRING}) \\? (?<default_answer>{STRING})$",
	# menu label_name?:
	MENU = "^menu( (?<label>{NAME}))?:$",
	# "like regex" (> label_name)?
	CHOICE = "^(?<text>{STRING})( > (?<label>{NAME}))?$",
	# jump label
	JUMP = "^jump (?<label>{NAME})( if (?<expression>.+))?$",
	# for setting Rakugo variables
	SET_VARIABLE = "(?<lvar_name>{VARIABLE}) = ((?<text>{STRING})|(?<number>{NUMERIC})|(?<rvar_name>{VARIABLE}))",
	# $ some_gd_script_code
#	IN_LINE_GDSCRIPT = "^\\$.*",
	# gdscript:
#	GDSCRIPT_BLOCK = "^gdscript:",
#	COMMENT = "^#.*",
#	TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
#	CONDITION = "(if|elif) (?<condition>.*)",
}

var other_regex :={
	VARIABLE_IN_STR = "\\<(?<variable>{VARIABLE})\\>",
}

var regex_cache := {}

var other_cache := {}

var stop_thread := false

enum State {Normal = 0, Menu, Jump}

var state = State.Normal

var menu_jump_index:int

var parsed_scripts:Dictionary

var current_thread:Thread

var current_semaphore:Semaphore

var threads:Dictionary

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

	for key in Regex:
		Regex[key] = Regex[key].format(Regex)

	for key in parser_regex:
		add_regex(key, parser_regex[key], regex_cache, "Parser, _init, failed " + key)
	
	for key in other_regex:
		add_regex(key, other_regex[key], other_cache, "Parser, _init, failed " + key)
		
	add_regex("VARIABLE", Regex["VARIABLE"], other_cache, "Parser, _init, failed VARIABLE")

func close() -> int:
	if current_thread and current_thread.is_active():
		var dico = threads[current_thread.get_id()]
		
		dico["stop"] = true
		dico["semaphore"].post()
	return OK

func execute_script(script_name:String, label_name:String) -> int:
	close()
	
	if parsed_scripts.has(script_name):
		current_thread = Thread.new()
	
		current_semaphore = Semaphore.new()
		
		var dico = {"thread":current_thread, "semaphore":current_semaphore, "file_base_name":script_name, "stop":false}
	
		if !label_name.empty():
			dico["label_name"] = label_name
	
		if current_thread.start(self, "do_execute_script", dico) != OK:
			current_thread = null
			
			current_semaphore = null
			
			threads.erase(current_thread.get_id())
			
			return FAILED
		return OK
	push_error("Rakugo does not have parse a script named: " + script_name)
	return FAILED

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

func parse_script(file_name:String) -> int:
	var file = File.new()
	
	if file.open(file_name, File.READ) != OK:
		push_error("can't open file : " + file_name)
		return ERR_FILE_CANT_OPEN
	
	var lines = file.get_as_text().split("\n", false)
	
	file.close()
	
	var parse_array:Array
	
	var labels:Dictionary
	
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
								var str_expression:String = result.get_string("expression")

								if str_expression.empty():
									parse_array.push_back([key, result])
									break

								var sub_results = other_cache["VARIABLE"].search_all(str_expression)

								var vars = []

								# Expression does not like '.'
								var vars_expression = []

								for sub_result in sub_results:
									var sub_result_str = sub_result.strings[0]
									
									if !vars.has(sub_result_str):
										vars.push_back(sub_result_str)

									var var_name_expr = sub_result.get_string("char_tag")

									if !var_name_expr.empty():
										var_name_expr += "_" + sub_result.get_string("var_name")

										str_expression = str_expression.replace(sub_result_str, var_name_expr)
									else:
										var_name_expr = sub_result.get_string("var_name")
									
									if !vars_expression.has(var_name_expr):
										vars_expression.push_back(var_name_expr)

								var expression = Expression.new()

								if expression.parse(str_expression, vars_expression) != OK:
									push_error("Parser: Error on line: " + str(i) + ", " + expression.get_error_text())
									return FAILED

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
	
	parsed_scripts[file_name.get_file().get_basename()] = {"parse_array":parse_array, "labels":labels}
	
	return OK

func do_execute_jump(jump_label:String, parse_array:Array, labels:Dictionary) -> int:
	var index := -1
	if labels.has(jump_label):
		index = labels[jump_label]
		
		if index >= parse_array.size():
			push_error("Parser, do_execute_script, JUMP, index out of range")
			index = -1
	else:
		push_error("Parser, do_execute_script, JUMP, unknow label")
		
	return index

func do_execute_script_end(thread:Thread, file_base_name:String):
	thread.wait_to_finish()
	
	if is_instance_valid(Rakugo):
		Rakugo.send_execute_script_finished(file_base_name)

func do_execute_script(parameters:Dictionary) -> int:
	var thread = parameters["thread"]
	
	threads[thread.get_id()] = parameters
	
	var semephore = parameters["semaphore"]
	
	var file_base_name = parameters["file_base_name"]
	
	var index := 0
	
	var parse_array:Array = parsed_scripts[file_base_name]["parse_array"]
	
	var labels = parsed_scripts[file_base_name]["labels"]
	
	if parameters.has("label_name"):
		index = do_execute_jump(parameters["label_name"], parse_array, labels)
		
		if index == -1:
			return FAILED
	
	while !parameters["stop"] and index < parse_array.size():
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
					
					if line[2].has_execute_failed():
						push_error("Execute: Error on line: " + str(index))
						return FAILED
				else:
					can_jump = true

				if can_jump:
					index = do_execute_jump(result.get_string("label"), parse_array, labels) - 1
				
				if index == -2:
					break
			
			"SAY":
				var text = remove_double_quotes(result.get_string("text"))
				
				var sub_results = other_cache["VARIABLE_IN_STR"].search_all(text)
				
				for sub_result in sub_results:
					var var_ = Rakugo.get_variable(sub_result.get_string("variable"))
					
					if var_:
						text = text.replace(sub_result.strings[0], var_)
				
				Rakugo.say(result.get_string("character_tag"), text)

				Rakugo.step()

				semephore.wait()
				
			"CHARACTER_DEF":
				Rakugo.define_character(result.get_string("tag"), result.get_string("name"))
				
			"ASK":
				Rakugo.ask(result.get_string("variable"), result.get_string("character_tag"), remove_double_quotes(result.get_string("question")), remove_double_quotes(result.get_string("default_answer")))

				semephore.wait()
				
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

				semephore.wait()
				
				if menu_jumps.has(menu_jump_index):
					var jump_label = menu_jumps[menu_jump_index]

					index = do_execute_jump(jump_label, parse_array, labels) - 1
				
					if index == -2:
						return FAILED
		
			"SET_VARIABLE":
				var rvar_name = result.get_string("rvar_name")
				var text = result.get_string("text")
				
				var value
				
				if !rvar_name.empty():
					value = Rakugo.get_variable(rvar_name)
					
					if !value:
						push_error("Parser::do_execute_script::SET_VARIABLE, variable " + rvar_name + " does not exist !")
						return FAILED
				elif !text.empty():
					value = remove_double_quotes(text)
				else:
					value = result.get_string("number")

					if value.is_valid_integer():
						value = int(value)
					else:
						value = float(value)

				Rakugo.set_variable(result.get_string("lvar_name"), value)
			_:
				Rakugo.emit_signal("parser_unhandled_regex", line[0], result)
		
		index += 1
	
	call_deferred("do_execute_script_end", thread, file_base_name)
	
	return OK

func parse_and_execute(file_name:String, label_name:String):
	if parse_script(file_name) == OK:
		return execute_script(file_name.get_file().get_basename(), label_name)
	return FAILED

func _on_menu_return(index:int):
	menu_jump_index = index
	
	current_semaphore.post()

func _on_ask_return(result):
	current_semaphore.post()
