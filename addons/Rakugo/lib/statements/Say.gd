extends Node

var default_parameters = {}
var default_narrator = null

func _ready():
	default_narrator = Character.new()
	default_narrator.init(
		Settings.get(SettingsList.narrator_name), 
		"", Settings.get(SettingsList.narrator_color))
	default_parameters = Settings.get(SettingsList.default_say_parameters, {}, false)


func exec(character, text:String, parameters := {}) -> void:
	character = _get_character(character)

	# parameters > character default parameters > project parameters
	if character:
		parameters = _apply_default(parameters, character.say_parameters)
	
	parameters = _apply_default(parameters, default_parameters)
	Rakugo.emit_signal("say", character, text, parameters)


#Utils functions
func _get_character(character):
	if character is String:
		character = Rakugo.get_current_store().get(character)
	return character

func get_narrator():
	return default_narrator

func _apply_default(input:Dictionary, default:Dictionary):
	var output = input.duplicate()
	for k in default.keys():
		if not output.has(k):
			output[k] = default[k]
	return output
