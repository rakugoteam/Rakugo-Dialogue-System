@tool
extends EditorPlugin

var editor_interface : EditorInterface
var script_editor : ScriptEditor
var code_highlighter : EditorSyntaxHighlighter
var default_script_types : PackedStringArray
var editor_settings : EditorSettings
var default_text_extensions : String

func _enter_tree():
	# Initialization of the plugin goes here
	add_autoload_singleton("Rakugo", "res://addons/Rakugo/Rakugo.gd")

	ProjectSettings.set_setting("addons/rakugo/game_version", "1.0.0")
	ProjectSettings.set_setting("addons/rakugo/history_length", 30)
	ProjectSettings.set_setting("addons/rakugo/narrator/name", "narrator")
	ProjectSettings.set_setting("addons/rakugo/debug", false)
	ProjectSettings.set_setting("addons/rakugo/save_folder", "user://saves")

	default_script_types = ProjectSettings.get_setting(
		"editor/script/search_in_file_extensions")
	
	if !("rk" in default_script_types):
		var script_types = default_script_types.duplicate()
		script_types.append("rk")
		ProjectSettings.set_setting(
			"editor/script/search_in_file_extensions",
			script_types
		)

	print("Rakugo is enabled")

func _exit_tree():
	ProjectSettings.set_setting("addons/rakugo/game_version", null)
	ProjectSettings.set_setting("addons/rakugo/history_length", null)
	ProjectSettings.set_setting("addons/rakugo/narrator/name", null)
	ProjectSettings.set_setting("addons/rakugo/debug", null)
	ProjectSettings.set_setting("addons/rakugo/save_folder", null)

	ProjectSettings.set_setting(
		"editor/script/search_in_file_extensions",
		default_script_types
	)