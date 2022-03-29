extends Node

var default_narrator = null

func _ready():
	default_narrator = Character.new()
	default_narrator.init(
		ProjectSettings.get(Rakugo.narrator_name), 
		"", Color.transparent)

func exec(character, text:String) -> void:
	character = _get_character(character)

	Rakugo.emit_signal("say", character, text)

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
