extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const file_name = "res://Test/TestParser/Timeline.rk"

var thread:Thread

# Called when the node enters the scene tree for the first time.
func _ready():
	Rakugo.connect("say", self, "_on_say")
	
	var parser = Parser.new()
	
	thread = Thread.new()
	thread.start(parser, "parse_script", file_name)

func _exit_tree():
	if thread and thread.is_active():
		thread.wait_to_finish()

func _on_say(character:Character, text):
	prints("TestParser", "say", character.name if character else "null", text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
