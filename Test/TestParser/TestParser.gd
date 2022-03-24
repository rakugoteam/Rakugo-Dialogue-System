extends Node

const file_name = "res://Test/TestParser/Timeline.rk"

# Called when the node enters the scene tree for the first time.
func _ready():
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("ask", self, "_on_ask")
	Rakugo.connect("menu", self, "_on_menu")
	
	Rakugo.parse_script(file_name)

func _on_say(character:Character, text:String):
	prints("TestParser", "say", character.name if character else "null", text)

func _on_step():
	prints("TestParser", "\nPress 'Enter' to continue...\n")
	
func _on_ask(character:Character, question:String, default_answer:String):
	prints("TestParser", "ask", character.name if character else "null", question, default_answer)

func _on_menu(choices):
	prints("TestParser", "menu", choices)

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
		
	if Rakugo.is_waiting_ask_return() and Input.is_action_just_pressed("ui_up"):
		Rakugo.ask_return("Bob")
		
	if Rakugo.is_waiting_menu_return() and Input.is_action_just_pressed("ui_down"):
		Rakugo.menu_return(0)
