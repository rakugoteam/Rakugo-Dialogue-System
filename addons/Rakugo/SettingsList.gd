extends Object
class_name SettingsList

# Rakugo
const force_reload := "rakugo/game/scenes/force_reload"
const rollback_steps := "rakugo/game/store/rollback_steps"
const history_length := "rakugo/game/store/history_length"
const narrator_name := "rakugo/default/narrator/name"
const debug := "rakugo/editor/debug"
const save_folder := "rakugo/saves/save_folder"
const test_mode := "rakugo/saves/test_mode"

#Godot
const game_title := "application/config/name"
const main_scene := "application/run/main_scene"
const width := "display/window/size/width"
const height := "display/window/size/height"
const fullscreen := "display/window/size/fullscreen"
const maximized := "display/window/size/maximized"

var default_property_list:Dictionary = {
	force_reload : [
		false, PropertyInfo.new(
			"", TYPE_BOOL, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],

	rollback_steps : [
		10, PropertyInfo.new(
			"", TYPE_INT, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	history_length : [
		30, PropertyInfo.new(
			"", TYPE_INT, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],
  
	narrator_name : [
		"", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	debug : [
		false, PropertyInfo.new(
			"", TYPE_BOOL, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],

	save_folder : [
		"res://saves", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_DIR, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	test_mode : [
		true, PropertyInfo.new(
			"", TYPE_BOOL, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],
}
