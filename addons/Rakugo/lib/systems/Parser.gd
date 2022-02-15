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
#	TRANSLATION = "\\[TR:(?<tr>.*?)]\\",
	CONDITION = "(if|elif) (?<condition>.*)",
	STRING = "\"(?<string>.*)\"",
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
	CHARACTER_DEF = "^character (?<tag>{VALID_VARIABLE}) \"(?<character_name>.*)\"",
	# character_tag? say STRING|MULTILINE_STRING
	SAY = "^(?<character_tag>{VALID_VARIABLE})? (?<text>{STRING|MULTILINE_STRING})",
	# var_name = ask "please enter text" 
	ASK = "^(?<var_name>{VALID_VARIABLE}) (?<assignment_type>{TOKEN_ASSIGNMENT} ask (?<text>{STRING}))",
	# menu menu_name? :
	#   choice1 "label":
	#     say "text"
	MENU = "^menu (?<menu_name>{VALID_VARIABLE})?:",
	#   choice1 "label":
	CHOICE = "^(?<choice>{VALID_VARIABLE}) (?<label>{STRING}):",
	JUMP = "jump (?<jump_to_title>.*)",
}

var regex_cache := {}

func _init():
	for t in Tokens.keys():
		Tokens[t] = Tokens[t].format(Regex)
		# prints(t, Tokens[t])
		
		var reg := RegEx.new()
		reg.compile(Tokens[t])
		
		regex_cache[t] = reg

	for r in Regex.keys():
		Regex[r] = Regex[r].format(Tokens)
		
		Regex[r] = Regex[r].format(Regex)
		# prints(r, Regex[r])

		var reg := RegEx.new()
		reg.compile(Regex[r])
		
		regex_cache[r] = reg

func parse_script(file:File) -> Dictionary:
	var dialogues: Dictionary = { init_dialogue_name:[] }
	var current_dialogue = dialogues[init_dialogue_name]

	# var known_translations = {}
	# var errors: Array = []
	# var parent_stack: Array = []
	
	while not file.eof_reached():
		var line = file.get_line()

		if line.empty():
			continue

		var result
		result = regex_cache["CHARACTER_DEF"].search(line)
		if result:
			current_dialogue.append(line)

		result = regex_cache["GDSCRIPT_BLOCK"].search(line)
		if result:
			current_dialogue.append(line)

		result = regex_cache["IN_LINE_GDSCRIPT"].search(line)
		if result:
			current_dialogue.append(line)

		result = regex_cache["DIALOGUE"].search(line)
		if result:
			var dialogue_name = result.get_string("dialogue_name")
			
			if !dialogues.has(dialogue_name):
				dialogues[dialogue_name] = []
			
			current_dialogue = dialogues[dialogue_name]
		else:
			current_dialogue.append(line)

#	for dialogue_name in dialogues.keys():
#		dialogues[dialogue_name] = parse_dialogue(dialogues[dialogue_name])
	
	return dialogues

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
