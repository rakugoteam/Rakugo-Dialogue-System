extends Node
class_name RakugoTextParser

func parse(text:String, _markup:="", editor:=false):
	if null in [ProjectSettings, SettingsList]:
		return text

	if _markup in ["", "game_setting"]:
		if editor:
			var setting = ProjectSettings.get(SettingsList.markup)
			if setting != null:
				_markup = setting
			
		else:
			_markup = Settings.get(SettingsList.markup)
	
	text = dirty_escaping(text)
	match _markup:
		"renpy":
			text = convert_renpy_markup(text)
			
		"markdown":
			text = convert_markdown_markup(text)
	
	if !editor:
		text = replace_variables(text, editor)
		
	return text

func convert_markdown_markup(text:String):
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("!\u200B?\\[\u200B?\\]\\(([^\\(\\)\\[\\]]+)\\)")# ![](path/to/img)
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]" + result.get_string(1) + "[/img]"
			output = regex_replace(result, output, replacement)
	text = output

	# either plain "prot://url" and "[link](url)" and not "[img]url[\img]"
	re.compile("(\\[img\\][^\\[\\]]*\\[\\/img\\])|(?:(?:\\[([^\\]\\)]+)\\]\\(([a-zA-Z]+:\\/\\/[^\\)]+)\\))|([a-zA-Z]+:\\/\\/[^ \\[\\]]*[a-zA-Z0-9_]))")

	for result in re.search_all(text):
		# having anything in 1 meant it matched "[img]url[\img]"
		if result.get_string() and not result.get_string(1): 
			if result.get_string(4):
				replacement = "[url]" + result.get_string(4) + "[/url]"
			else:
				# That can can be the user erroneously writing "[b](url)[\b]" need to be pointed in the doc
				replacement = "[url=" + result.get_string(3) + "]" + result.get_string(2) + "[/url]"
			output = regex_replace(result, output, replacement)
	text = output

	re.compile("\\*\\*([^\\*]+)\\*\\*")# **bold**
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[b]" + result.get_string(1) + "[/b]"
			output = regex_replace(result, output, replacement)
	text = output
	
	re.compile("\\*([^\\*]+)\\*")# *italic*
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[i]" + result.get_string(1) + "[/i]"
			output = regex_replace(result, output, replacement)
	text = output

	re.compile("~~([^~]+)~~")# ~~strike through~~
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[s]" + result.get_string(1) + "[/s]"
			output = regex_replace(result, output, replacement)
	text = output

	re.compile("`([^`]+)`")# `code`
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[code]" + result.get_string(1) + "[/code]"
			output = regex_replace(result, output, replacement)
	text = output

	return text

func convert_renpy_markup(text:String):
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("(?<!\\[)\\[([\\w.]+)\\]")# Convert compatible variable inclusion
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "<" + result.get_string(1) + ">")
	text = output
	
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")# match unescaped "{a=" and "{/a}"
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[" + result.get_string(1) + "url" + result.get_string(2) + "]"
			output = regex_replace(result, output, replacement)
	text = output
	
	re.compile("(?<!\\{)\\{img=([^\\}]+)\\}")# match unescaped "{img=<path>}"
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]" + result.get_string(1) + "[/img]"
			output = regex_replace(result, output, replacement)
	text = output
	
	re.compile("(?:(?<!\\{)\\{[^\\{\\}]+)(\\})")# math "}" part of a valid tag
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "]", 1)
	text = output
	
	re.compile("(?<!\\{)\\{(?!\\{)")# match unescaped "{"
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "[")
	text = output
	
	re.compile("([\\{]+)")# match escaped braces "{{" transform them into "{"
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "{")
	text = output

	return text

func dirty_escaping(text:String):
	var re = RegEx.new()
	var output = "" + text
	
	re.compile("(\\\\)(.)")
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "\u200B" + result.get_string(2) + "\u200B")
	
	return output

func replace_variables(text:String, editor:=false):
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("<([\\w.]+)>")
	for result in re.search_all(text):
		if result.get_string():
			
			if editor:
				replacement = str(get_variable(result.get_string(1)))
			else:
				replacement = "[code]" + result.get_string(1) + "[/code]"

			output = regex_replace(result, output, replacement)
	
	return output

func regex_replace(result:RegExMatch, output:String, replacement:String, string_to_replace=0):
	var offset = output.length() - result.subject.length()
	var left = output.left(result.get_start(string_to_replace) + offset)
	var right = output.right(result.get_end(string_to_replace) + offset)
	return left + replacement + right 

func get_variable(var_name:String):
	var parts = var_name.split('.', false)
	
	var output = Rakugo.store
	var i = 0
	var error = false
	while output and i < parts.size():
		output = output.get(parts[i])
		i += 1
		if not output:
			error = true
			push_warning("The variable '%s' does not exist." % var_name)
	if error:
		output = null
	return output
