@tool
extends EditorPlugin

var script_types: PackedStringArray
var text_types: String
var editor_settings: EditorSettings

func _enter_tree():
	# Initialization of the plugin goes here
	add_autoload_singleton("Rakugo", "res://addons/Rakugo/Rakugo.gd")

	# try to import setting from version 2.2
	var game_version := ProjectSettings.get_setting("addons/rakugo/game_version", 1.0)
	var narrator_name := ProjectSettings.get_setting("addons/rakugo/narrator/name", "narrator")
	var debug := ProjectSettings.get_setting("addons/rakugo/debug", false)
	var save_folder := ProjectSettings.get_setting("addons/rakugo/save_folder", "user://saves")

	# remove old settings
	ProjectSettings.set_setting("addons/rakugo/game_version", null)
	ProjectSettings.set_setting("addons/rakugo/history_length", null)
	ProjectSettings.set_setting("addons/rakugo/narrator/name", null)
	ProjectSettings.set_setting("addons/rakugo/debug", null)
	ProjectSettings.set_setting("addons/rakugo/save_folder", null)

	ProjectSettings.set_setting(Rakugo.game_version, game_version)
	ProjectSettings.set_setting(Rakugo.narrator_name, narrator_name)
	ProjectSettings.set_setting(Rakugo.debug, debug)
	ProjectSettings.set_setting(Rakugo.save_folder, save_folder)

	script_types = ProjectSettings.get_setting(Rakugo.editor_text_files)
	if !("rk" in script_types):
		script_types.append("rk")
		ProjectSettings.set_setting(Rakugo.editor_text_files, script_types)
	
	editor_settings = get_editor_interface().get_editor_settings()
	text_types = editor_settings.get(Rakugo.docks_text_files)
	if !("rk" in text_types):
		text_types += ",rk"
		ProjectSettings.set_setting(Rakugo.docks_text_files, text_types)
	
	print("Rakugo is enabled")

func _exit_tree():
	ProjectSettings.set_setting(Rakugo.game_version, null)
	ProjectSettings.set_setting(Rakugo.narrator_name, null)
	ProjectSettings.set_setting(Rakugo.debug, null)
	ProjectSettings.set_setting(Rakugo.save_folder, null)
	remove_autoload_singleton("Rakugo")
	print("Rakugo is disabled")
