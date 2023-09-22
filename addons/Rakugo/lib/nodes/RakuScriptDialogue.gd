extends Node
class_name RakuScriptDialogue

@export_file("*.rk") var raku_script : String
@export var starting_label_name := ""
@export var auto_start := false

func _ready():
	if auto_start:
		start_dialogue()

func start_dialogue():
	start_dialogue_from_label(starting_label_name)

func start_dialogue_from_label(label_name : String):
	Rakugo.parse_and_execute_script(raku_script, label_name)
