extends RefCounted

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
	TOKEN_NUMERIC = "-?[0-9]\\.?[0-9]*",
}

var Regex := {
	NAME = "[a-zA-Z][a-zA-Z_0-9]*",
	NUMERIC = "-?[0-9]\\.?[0-9]*",
	STRING = "\".+?\"",
	VARIABLE = "((?<char_tag>{NAME})\\.)?(?<var_name>{NAME})",
	ASSIGNMENT = "(?<assignment>=|\\+=|\\-=|\\*=|\\/=)"
#	MULTILINE_STRING = "\"\"\"(?<string>.*)\"\"\"",
}

# Regex for RenScript
# Regex in this language can be extended by the other addons
# Order is matter !
var parser_regex :={
	# exit dialogue
	EXIT = "^\\s*exit$",
	# menu label_name?:
	MENU = "^menu( (?<label>{NAME}))?:$",
	# dialogue label_name:
	DIALOGUE = "^(?<label>{NAME}):$",
	# character tag = "character_name"
	CHARACTER_DEF = "^character (?<tag>{NAME}) \"(?<name>.*)\"$",
	# character_tag? "say"
	SAY = "^((?<character_tag>{NAME}) )?(?<text>{STRING})$",
	# var_name = character_tag? "please enter text" 
	ASK = "^(?<variable>{VARIABLE})\\s*=\\s*\\?\\s*((?<character_tag>{NAME}) )?(?<question>{STRING})( (?<default_answer>{STRING}))?$",
	# "like regex" (> label_name)?
	CHOICE = "^(?<text>{STRING})( > (?<label>{NAME}))?$",
	# jump label
	JUMP = "^jump (?<label>{NAME})( if (?<expression>.+))?$",
	# for setting Rakugo variables
	SET_VARIABLE = "^(?<lvar_name>{VARIABLE})\\s*{ASSIGNMENT}\\s*((?<text>{STRING})|(?<number>{NUMERIC})|(?<rvar_name>{VARIABLE}))$",
	# $ some_gd_script_code
#	IN_LINE_GDSCRIPT = "^\\$.*",
	# gdscript:
#	GDSCRIPT_BLOCK = "^gdscript:",
#	TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
#	CONDITION = "(if|elif) (?<condition>.*)",
}

var other_regex :={
	VARIABLE_IN_STR = "\\<(?<variable>{VARIABLE})\\>",
}

var regex_cache := {}

var other_cache := {}

enum State {Normal = 0, Menu, Jump}

var state:int

func add_regex(key:String, regex:String, cache:Dictionary, error:String):
	regex = regex.format(Regex)
	
	var reg := RegEx.new()
	if reg.compile(regex) != OK:
		push_error(error)
		
	cache[key] = reg
	
func add_regex_at_runtime(key:String, regex:String):
	add_regex(key, regex, regex_cache, "Parser, add_regex_at_runtime, failed " + key)

func _init():
	for key in Regex:
		Regex[key] = Regex[key].format(Regex)

	for key in parser_regex:
		add_regex(key, parser_regex[key], regex_cache, "Parser, _init, failed " + key)
	
	for key in other_regex:
		add_regex(key, other_regex[key], other_cache, "Parser, _init, failed " + key)
		
	add_regex("VARIABLE", Regex["VARIABLE"], other_cache, "Parser, _init, failed VARIABLE")

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

func treat_string(s:String) -> String:
	s = s.substr(1, s.length()-2)
	return s.replace("\\n", "\n").replace("\\t", "\t")

func parse_script(lines:PackedStringArray) -> Dictionary:
	if lines.is_empty():
		push_error("Parser, parse_script : lines is empty !")
		return {}
	
	var parse_array:Array
	
	var labels:Dictionary
	
	var indent_count:int
	
	var menu_choices
	
	var current_menu_result
	
	state = State.Normal
	
	for i in lines.size():
		var line = lines[i]

		line = line.strip_edges()

		var isEmptyLine = line.is_empty() or line.begins_with("#")
	
		if state == State.Menu:
			var result = regex_cache["CHOICE"].search(line)

			if isEmptyLine or !result:
				if !menu_choices.is_empty():
					parse_array.push_back(["MENU", current_menu_result, menu_choices])
				state = State.Normal
			else:
#				prints("Parser", "parse_script", "CHOICE")
#
#				for key in result.names:
#					prints(" ", key, result.get_string(key))
				
				var dic_result := {
					"text":treat_string(result.get_string("text")),
					"label":result.get_string("label")
				}

				menu_choices.push_back(dic_result)
				
				if i == lines.size() - 1:
					parse_array.push_back(["MENU", current_menu_result, menu_choices])
				
				continue
			
		if isEmptyLine:
			continue
	
		var have_find_key := false
	
		for key in regex_cache:
			var result = regex_cache[key].search(line)
			
			if result:
				have_find_key = true

				match(key):
					"MENU":
						current_menu_result = result
			
						menu_choices = []
						
						state = State.Menu
						
						var label = result.get_string("label")
						
						if !label.is_empty():
							labels[label] = parse_array.size()
						
					"DIALOGUE":
						var dialogue_label = result.get_string("label")
		
						labels[dialogue_label] = parse_array.size()
					
					"JUMP":
						var str_expression:String = result.get_string("expression")

						if str_expression.is_empty():
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

							if !var_name_expr.is_empty():
								var_name_expr += "_" + sub_result.get_string("var_name")

								str_expression = str_expression.replace(sub_result_str, var_name_expr)
							else:
								var_name_expr = sub_result.get_string("var_name")
							
							if !vars_expression.has(var_name_expr):
								vars_expression.push_back(var_name_expr)

						var expression = Expression.new()

						if expression.parse(str_expression, vars_expression) != OK:
							push_error("Parser: Error on line: " + str(i+1) + ", " + expression.get_error_text())
							return {}

						parse_array.push_back([key, result, expression, vars])

					"SAY":
						var dic_result := {
							"text":treat_string(result.get_string("text")),
							"character_tag":result.get_string("character_tag")
						}

						parse_array.push_back([key, dic_result])

					"ASK":
						var dic_result := {
							"variable":result.get_string("variable"),
							"character_tag":result.get_string("character_tag"),
							"question":treat_string(result.get_string("question")),
							"default_answer":treat_string(result.get_string("default_answer"))
						}

						parse_array.push_back([key, dic_result])

					"SET_VARIABLE":
						var dic_result := {
							"lvar_name":result.get_string("lvar_name"),
							"assignment":result.get_string("assignment"),
							"rvar_name":result.get_string("rvar_name"),
							"number":result.get_string("number"),
							"text":treat_string(result.get_string("text"))
						}

						parse_array.push_back([key, dic_result])
					_:
						parse_array.push_back([key, result])
				break

		if (not have_find_key):
			push_error("Parser: Error on line: " + str(i+1) + ", can not parse it !")
			return {}
			
	return {"parse_array":parse_array, "labels":labels}
