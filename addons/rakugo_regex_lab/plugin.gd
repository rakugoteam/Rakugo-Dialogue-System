@tool
extends EditorPlugin

const regex_lab_path := "res://addons/rakugo_regex_lab/regex.tscn"
var command_palette := get_editor_interface().get_command_palette()
var editor_interface := get_editor_interface().get_base_control()
var regex_lab : Window

func _enter_tree():
	add_tool_menu_item("Rakugo Regex Lab", show_regex_lab)
	command_palette.add_command(
		"Rakugo Regex Lab", "regex_lab", show_regex_lab)

func show_regex_lab():
	if regex_lab == null:
		regex_lab = load(regex_lab_path).instantiate() as Window
		editor_interface.add_child.call_deferred(regex_lab)

	regex_lab.theme = editor_interface.theme
	regex_lab.popup_centered(regex_lab.size)

func _exit_tree():
	remove_tool_menu_item("Rakugo Regex Lab")
	command_palette.remove_command("regex_lab")
	
	if regex_lab:
		regex_lab.queue_free()