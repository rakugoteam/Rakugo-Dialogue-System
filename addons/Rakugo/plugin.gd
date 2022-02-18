tool
extends EditorPlugin

var rakugo_tools
var tools_menu
var tm_container

var default_property_list = SettingsList.new().default_property_list

func init_project_settings():
	for property_key in default_property_list.keys():
		var property_value = default_property_list[property_key]
		ProjectTools.set_setting(property_key, property_value[0], property_value[1])
	
	# move setting to the top of the list
	ProjectSettings.set_order(default_property_list.keys()[0], 1)

func _enter_tree():
	# Initialization of the plugin goes here
	add_autoload_singleton("Rakugo", "res://addons/Rakugo/Rakugo.tscn")
	add_autoload_singleton("Settings", "res://addons/Rakugo/Settings.gd")
	
	init_project_settings()
	print("Rakugo is enabled")

func remove_tools():
	remove_control_from_container(tm_container, tools_menu)

	tools_menu.free()
	rakugo_tools.free()

func _exit_tree():
	remove_tools()
