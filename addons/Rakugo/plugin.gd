@tool
extends EditorPlugin

var script_types: PackedStringArray
var text_types: String
var editor_settings: EditorSettings
var _rakugo: Node

func _enter_tree():
	# Initialization of the plugin goes here
	add_autoload_singleton("Rakugo", "res://addons/Rakugo/Rakugo.gd")
	
	# this fix error with enabling plugin in new godot 4.4+ projects
	_rakugo = load("res://addons/Rakugo/Rakugo.gd").new()

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

	ProjectSettings.set_setting(_rakugo.game_version, game_version)
	ProjectSettings.set_setting(_rakugo.narrator_name, narrator_name)
	ProjectSettings.set_setting(_rakugo.debug, debug)
	ProjectSettings.set_setting(_rakugo.save_folder, save_folder)

	script_types = ProjectSettings.get_setting(_rakugo.editor_text_files)
	if !("rk" in script_types):
		script_types.append("rk")
		ProjectSettings.set_setting(_rakugo.editor_text_files, script_types)
	
	editor_settings = get_editor_interface().get_editor_settings()
	text_types = editor_settings.get(_rakugo.docks_text_files)
	if !("rk" in text_types):
		text_types += ",rk"
		ProjectSettings.set_setting(_rakugo.docks_text_files, text_types)
	
	print("Rakugo is enabled")

func _exit_tree():
	ProjectSettings.set_setting(_rakugo.game_version, null)
	ProjectSettings.set_setting(_rakugo.narrator_name, null)
	ProjectSettings.set_setting(_rakugo.debug, null)
	ProjectSettings.set_setting(_rakugo.save_folder, null)
	remove_autoload_singleton("Rakugo")
	print("Rakugo is disabled")
