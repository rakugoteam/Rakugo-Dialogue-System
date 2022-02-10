extends Object
class_name SettingsList

# Rakugo
const game_version := "addons/rakugo/game_version"
const force_reload := "addons/rakugo/force_reload"
const auto_mode_delay := "addons/rakugo/auto_mode_delay"
const skip_delay := "addons/rakugo/skip_delay"
const rollback_steps := "addons/rakugo/rollback_steps"
const history_length := "addons/rakugo/history_length"
const narrator_name := "addons/rakugo/narrator/name"
const debug := "addons/rakugo/debug"
const save_folder := "addons/rakugo/save_folder"
const test_mode := "addons/rakugo/test_mode"

#Godot
const game_title := "application/config/name"
const main_scene := "application/run/main_scene"
const width := "display/window/size/width"
const height := "display/window/size/height"
const fullscreen := "display/window/size/fullscreen"
const maximized := "display/window/size/maximized"

func crate_property(type:int, value) -> Array:
		return [value, PropertyInfo.new(
			"", type, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR
		)]

var default_property_list:Dictionary = {
	game_version: crate_property(TYPE_STRING, "1.0.0"), 
	force_reload : crate_property(TYPE_BOOL, false),
	auto_mode_delay : crate_property(TYPE_INT, 3),
	skip_delay : crate_property(TYPE_INT, 0.5),
	rollback_steps : crate_property(TYPE_INT, 10),
	history_length : crate_property(TYPE_INT, 30),
	narrator_name : crate_property(TYPE_STRING, ""),
	debug : crate_property(TYPE_BOOL, false),
	save_folder : crate_property(TYPE_STRING, "res://saves"),
	test_mode : crate_property(TYPE_BOOL, false),
}
