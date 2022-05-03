extends Node
class_name RakuScriptDialogue

export(String, FILE, "*.rk") var raku_script : String
export var auto_start : bool

func _ready():
	if auto_start:
		start_dialogue()

func start_dialogue():
	Rakugo.parse_script(raku_script)

