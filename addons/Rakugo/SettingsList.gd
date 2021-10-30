extends Object
class_name SettingsList

# Rakugo
const game_version := "rakugo/game/info/version"
const game_credits := "rakugo/game/info/credits"
const scene_links := "rakugo/game/scenes/scene_links"
const force_reload := "rakugo/game/scenes/force_reload"
const rollback_steps := "rakugo/game/store/rollback_steps"
const history_length := "rakugo/game/store/history_length"
const markup := "rakugo/game/text/markup" 
const narrator_name := "rakugo/default/narrator/name"
const narrator_color := "rakugo/default/narrator/color"
const theme := "rakugo/default/gui/theme"
const typing_effect_delay := "rakugo/default/delays/typing_effect_delay"
const typing_effect_punctuation_factor := "rakugo/default/delays/typing_effect_punctuation_factor"
const auto_mode_delay := "rakugo/default/delays/auto_mode_delay"
const skip_delay := "rakugo/default/delays/skip_delay"
const default_say_parameters := "rakugo/default/statements/default_say_parameters"
const default_ask_parameters := "rakugo/default/statements/default_ask_parameters"
const default_menu_parameters := "rakugo/default/statements/default_menu_parameters"
const default_show_parameters := "rakugo/default/statements/default_show_parameters"
const debug := "rakugo/editor/debug"
const save_folder := "rakugo/saves/save_folder"
const save_screen_layout := "rakugo/saves/save_screen_layout"
const test_mode := "rakugo/saves/test_mode"

#Godot
const game_title := "application/config/name"
const main_scene := "application/run/main_scene"
const width := "display/window/size/width"
const height := "display/window/size/height"
const fullscreen := "display/window/size/fullscreen"
const maximized := "display/window/size/maximized"

var default_property_list:Dictionary = {
	 game_version : [
		"0.0.1", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],
	
	 game_credits : [
		"Your Company", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	scene_links : [
		"res://game/scene_links.tres", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_FILE, 
			"*.tres", PROPERTY_USAGE_DEFAULT)
	],
	
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

	markup : [
		"renpy", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_ENUM, 
			"renpy,bbcode,markdown",
			PROPERTY_USAGE_CATEGORY)
	],
  
	narrator_name : [
		"", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	narrator_color : [
		Color.white, PropertyInfo.new(
			"", TYPE_COLOR, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_DEFAULT)
	],

	theme : [
		"res://themes/Default/default.tres",
		PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_FILE, 
			"*.tres", PROPERTY_USAGE_DEFAULT)
	],

	typing_effect_delay : [
		0.1, PropertyInfo.new(
			"", TYPE_REAL, PROPERTY_HINT_EXP_RANGE, 
			"0.005, 1.0,or_greater", PROPERTY_USAGE_DEFAULT)
	],

	typing_effect_punctuation_factor : [
		4.0, PropertyInfo.new(
			"", TYPE_REAL, PROPERTY_HINT_EXP_RANGE, 
			"0.1, 5.0,or_greater", PROPERTY_USAGE_DEFAULT)
	],

	auto_mode_delay : [
		3, PropertyInfo.new(
			"", TYPE_REAL, PROPERTY_HINT_RANGE, 
			"0.1, 10.0", PROPERTY_USAGE_DEFAULT)
	],

	skip_delay : [
		0.1, PropertyInfo.new(
			"", TYPE_REAL, PROPERTY_HINT_EXP_RANGE, 
			"0.0, 2.0", PROPERTY_USAGE_DEFAULT)
	],

	default_say_parameters : [
		{
			"style": "default"
		}, PropertyInfo.new(
			"", TYPE_DICTIONARY, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],

	default_ask_parameters : [
		{
			"style": "default"
		}, PropertyInfo.new(
			"", TYPE_DICTIONARY, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],

	default_menu_parameters : [
		{
			"style": "default"
		}, PropertyInfo.new(
			"", TYPE_DICTIONARY, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],

	default_show_parameters : [
		{}, PropertyInfo.new(
			"", TYPE_DICTIONARY, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
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

	save_screen_layout : [
		"save_pages", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_ENUM, 
			"save_pages,save_list", PROPERTY_USAGE_DEFAULT)
	],

	test_mode : [
		true, PropertyInfo.new(
			"", TYPE_BOOL, PROPERTY_HINT_NONE, 
			"", PROPERTY_USAGE_EDITOR)
	],
}
