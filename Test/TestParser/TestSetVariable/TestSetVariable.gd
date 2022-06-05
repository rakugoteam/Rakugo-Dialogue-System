extends Node

const file_name = "res://Test/TestParser/TestSetVariable/TestSetVariable.rk"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rakugo.parse_script(file_name)
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	
func _on_step():
	prints("Press 'Enter' to continue...\n")

func _on_say(character:Dictionary, text:String):
	prints("Test if a is int")

	var a = Rakugo.get_variable("aaa")
	
	print(a)

	if typeof(a) == TYPE_INT:
		prints("success")
	else:
		prints("failed")


	prints("Test if b is float")

	var b = Rakugo.get_variable("bbb")
	
	print(b)

	if typeof(b) == TYPE_REAL:
		prints("success")
	else:
		prints("failed")


	prints("Test if c is string")

	var c = Rakugo.get_variable("ccc")
	
	print(c)

	if typeof(c) == TYPE_STRING:
		prints("success")
	else:
		prints("failed")


	prints("Test if d == a")

	var d = Rakugo.get_variable("ddd")
	
	print(d)

	if d == a:
		prints("success")
	else:
		prints("failed")


	prints("Test error when var does not exist")

	Rakugo.get_variable("eee")
	
	pass # Replace with function body.

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
