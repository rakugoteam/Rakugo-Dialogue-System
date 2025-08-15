@tool
extends EditorPlugin

var dialogue_highlighter: DialogueHighlighter
var settings = EditorInterface.get_editor_settings()

func set_settings():
	settings.set("RakuScript_Color/base_color", 0)
	settings.set("RakuScript_Color/comment_color", 0)
	settings.set("RakuScript_Color/character_color", 0)
	settings.set("RakuScript_Color/string_color", 0)
	settings.set("RakuScript_Color/var_color", 0)
	settings.set("RakuScript_Color/menu_color", 0)
	settings.set("RakuScript_Color/jump_color", 0)
	settings.set("RakuScript_Color/label_color", 0)
	settings.set("RakuScript_Color/num_color", 0)
	settings.set("RakuScript_Color/instr_color", 0)

func set_default_colors(first_load: bool):
	
	settings.add_property_info({
		"name": "RakuScript_Color/base_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/base_color", Color.LIGHT_GRAY, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/comment_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/comment_color", Color.DIM_GRAY, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/character_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/character_color", Color.INDIAN_RED, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/string_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/string_color", Color.WHEAT, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/var_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/var_color", Color.SKY_BLUE, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/menu_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/menu_color", Color.SEA_GREEN, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/jump_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/jump_color", Color.MEDIUM_PURPLE, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/label_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/label_color", Color.LIGHT_GREEN, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/num_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/num_color", Color.AQUAMARINE, first_load)
	
	settings.add_property_info({
		"name": "RakuScript_Color/instr_color",
		"type": TYPE_COLOR
	})
	settings.set_initial_value("RakuScript_Color/instr_color", Color.PALE_VIOLET_RED, first_load)

func _enter_tree() -> void:
	# Set default color if not existing.
	if not settings.has_setting("RakuScript_Color/base_color"):
		set_settings()
	set_default_colors(false)
	
	dialogue_highlighter = DialogueHighlighter.new()
	var script_editor = EditorInterface.get_script_editor()
	script_editor.register_syntax_highlighter(dialogue_highlighter)

func _exit_tree() -> void:
	if is_instance_valid(dialogue_highlighter):
		var script_editor = EditorInterface.get_script_editor()
		script_editor.unregister_syntax_highlighter(dialogue_highlighter)
		dialogue_highlighter = null


class DialogueHighlighter extends EditorSyntaxHighlighter:
	func _get_name() -> String:
		return "RakuScript"

	func _get_supported_languages() -> PackedStringArray:
		return ["TextFile"]

	func _get_line_syntax_highlighting(line: int) -> Dictionary:
		var color_map = {}
		var text_editor = get_text_edit()
		var str = text_editor.get_line(line)
		
		var settings = EditorInterface.get_editor_settings()

		var base_color: Color = settings.get("RakuScript_Color/base_color")
		var past_color: Color = settings.get("RakuScript_Color/base_color")
		
		var comment_color: Color = settings.get("RakuScript_Color/comment_color")
		var character_color: Color = settings.get("RakuScript_Color/character_color")
		var string_color: Color = settings.get("RakuScript_Color/string_color")
		var var_color: Color = settings.get("RakuScript_Color/var_color")
		var menu_color: Color = settings.get("RakuScript_Color/menu_color")
		var jump_color: Color = settings.get("RakuScript_Color/jump_color")
		var label_color: Color = settings.get("RakuScript_Color/label_color")
		var num_color: Color = settings.get("RakuScript_Color/num_color")
		var instr_color: Color = settings.get("RakuScript_Color/instr_color")

		# In all cases mask ou comentary.
		if str.strip_edges().begins_with("#"):
			color_map[0] = { "color": comment_color }
			return color_map

		# Not sure about this
		if str.strip_edges().begins_with("character"):
			color_map[0] = { "color": character_color }
			color_map[10] = { "color": base_color }
			
		if str.strip_edges().begins_with("jump"):
			color_map[0] = { "color": jump_color }
			color_map[4] = { "color": base_color }

		if str.strip_edges().ends_with(":"):
			color_map[0] = { "color": label_color }
		
		if str.strip_edges().begins_with("menu"):
			color_map[0] = { "color": menu_color }
		
		var i = 0
		# True if is ine one sentences
		var str_odd: bool = false
		var var_odd: bool = false
		
		var str_index = str.find("if")
		var var_index = str.split(".")
		
		for char in str:
			i += 1
			
			if char.is_valid_float() and var_odd == false and str_odd == false:
				color_map[i-1] = { "color": num_color }
				color_map[i] = { "color": base_color}
				
			if !str.begins_with("jump") and char == ">" and var_odd == false:
				color_map[i-1] = { "color": jump_color }
				color_map[i] = { "color": base_color}
				
			# strings, then variable
			if char == "\"" and str_odd == true:
				color_map[i-1] = { "color": base_color }
				str_odd = false
			if char == "\"" and str_odd == false:
				color_map[i-1] = { "color": string_color }
				past_color = string_color
				str_odd = true

			# strings, then variable
			if char == ">" and var_odd == true:
				color_map[i] = { "color": past_color }
				var_odd = false
			if char == "<" and var_odd == false:
				color_map[i-1] = { "color": var_color }
				var_odd = true
				
			if str.begins_with("jump") and str_index == i and var_odd == false and str_odd == false:
				color_map[str_index] = { "color": instr_color }
				color_map[str_index+2] = { "color": base_color }

		return color_map
