extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const file_name = "res://Test/TestParser/Timeline.rk"

var parser:Parser

# Called when the node enters the scene tree for the first time.
func _ready():
	Rakugo.connect("say", self, "_on_say")
	
	parser = Parser.new()
	
	parser.parse_script(file_name)

func _exit_tree():
	var thread = parser.thread
	
	if thread:
		parser.stop_thread = true
		
		parser.step_semaphore.post()
		
		thread.wait_to_finish()

func _on_say(character:Character, text):
	prints("TestParser", "say", character.name if character else "null", text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
