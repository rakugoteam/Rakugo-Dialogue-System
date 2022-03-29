tool
extends EditorPlugin

#var rakugo_tools
#var tools_menu
#var tm_container

func _enter_tree():
	# Initialization of the plugin goes here
	add_autoload_singleton("Rakugo", "res://addons/Rakugo/Rakugo.tscn")
	add_autoload_singleton("Settings", "res://addons/Rakugo/Settings.gd")
	
	#TODO look if setting are saved and load them
	
	ProjectSettings.set_setting("addons/rakugo/game_version", "1.0.0")
	ProjectSettings.set_setting("addons/rakugo/force_reload", false)
	ProjectSettings.set_setting("addons/rakugo/auto_mode_delay", 3)
	ProjectSettings.set_setting("addons/rakugo/skip_delay", 0.5)
	ProjectSettings.set_setting("addons/rakugo/rollback_steps", 10)
	ProjectSettings.set_setting("addons/rakugo/history_length", 30)
	ProjectSettings.set_setting("addons/rakugo/narrator/name", "narrator")
	ProjectSettings.set_setting("addons/rakugo/debug", false)
	ProjectSettings.set_setting("addons/rakugo/save_folder", "res://saves")
	ProjectSettings.set_setting("addons/rakugo/test_mode", false)
	
	print("Rakugo is enabled")

func _exit_tree():
	ProjectSettings.set_setting("addons/rakugo/game_version", null)
	ProjectSettings.set_setting("addons/rakugo/force_reload", null)
	ProjectSettings.set_setting("addons/rakugo/auto_mode_delay", null)
	ProjectSettings.set_setting("addons/rakugo/skip_delay", null)
	ProjectSettings.set_setting("addons/rakugo/rollback_steps", null)
	ProjectSettings.set_setting("addons/rakugo/history_length", null)
	ProjectSettings.set_setting("addons/rakugo/narrator/name", null)
	ProjectSettings.set_setting("addons/rakugo/debug", null)
	ProjectSettings.set_setting("addons/rakugo/save_folder", null)
	ProjectSettings.set_setting("addons/rakugo/test_mode", null)
	
#	remove_control_from_container(tm_container, tools_menu)
#
#	tools_menu.free()
#	rakugo_tools.free()
