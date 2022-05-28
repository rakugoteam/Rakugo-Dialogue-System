extends Node

const file_name = "res://Test/TestParser/TestJumpIf/TimelineJumpIf.rk"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	
	Rakugo.parse_script(file_name)

func _on_say(character:Dictionary, text:String):
	prints("TestParser", "say", character.get("name", "null"), text)

func _on_step():
	prints("TestParser", "Press 'Enter' to continue...\n")

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
