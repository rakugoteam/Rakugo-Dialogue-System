extends Node

const file_name = "res://Test/TestParser/Timeline.rk"

var parser:Parser

var is_waiting_step := false

var is_waiting_ask := false

# Called when the node enters the scene tree for the first time.
func _ready():
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("ask", self, "_on_ask")
	
	parser = Parser.new()
	
	parser.parse_script(file_name)

func _exit_tree():
	var thread = parser.thread
	
	if thread:
		parser.stop_thread = true
		
		parser.step_semaphore.post()
		
		thread.wait_to_finish()

func _on_say(character:Character, text:String):
	prints("TestParser", "say", character.name if character else "null", text)

func _on_step():
	is_waiting_step = true
	prints("TestParser", "\nPress 'Enter' to continue...\n")
	
func _on_ask(character:Character, question:String, default_answer:String):
	is_waiting_ask = true
	prints("TestParser", "ask", character.name if character else "null", question, default_answer)

func _process(delta):
	if is_waiting_step and Input.is_action_just_pressed("ui_accept"):
		is_waiting_step = false
		
		parser.step_semaphore.post()
		
	if is_waiting_ask and Input.is_action_just_pressed("ui_up"):
		is_waiting_ask = false
		
		Rakugo.ask_return("Bob")
