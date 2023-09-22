extends Node

const file_path = "res://Test/TestDocExample/Timeline.rk"

func _ready():
	Rakugo.add_custom_regex("HW", "^hello_world$")

	Rakugo.sg_custom_regex.connect(_on_custom_regex)
	Rakugo.sg_say.connect(_on_say)
	Rakugo.sg_step.connect(_on_step)
	Rakugo.sg_ask.connect(_on_ask)
	Rakugo.sg_menu.connect(_on_menu)

	Rakugo.parse_and_execute_script(file_path)

func _on_say(character:Dictionary, text:String):
	prints("say", character.get("name", "null"), text)

func _on_step():
	prints("Press 'Enter' to continue...")

func _on_ask(character:Dictionary, question:String, default_answer:String):
	prints("ask", character.get("name", "null"), question, default_answer)

func _on_menu(choices:Array):
	prints("menu", choices)

func _on_custom_regex(key:String, result:RegExMatch):
	prints("custom regex", key, result.strings)

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()

	if Rakugo.is_waiting_ask_return() and Input.is_action_just_pressed("ui_up"):
		Rakugo.ask_return("Bob")

	if Rakugo.is_waiting_menu_return() and Input.is_action_just_pressed("ui_down"):
		Rakugo.menu_return(0)
