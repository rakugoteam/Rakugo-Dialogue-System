extends Node

func _ready():
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("ask", self, "_on_ask")
	Rakugo.connect("menu", self, "_on_menu")
	Rakugo.connect("notify", self, "_on_notify")

func _on_say(character, text):
	printt("say", character, text)

func _on_step():
	printt("\nPress 'Enter' to continue...\n")

func _on_ask(default_answer, parameters):
	printt("ask", default_answer, parameters)
	
func _on_menu(choices, parameters):
	printt("menu", choices, parameters)
	
func _on_notify(text:String, parameters:Dictionary):
	printt("notify", text, parameters)

func _process(delta):
	if Rakugo.is_waiting_step and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
		
	if Rakugo.is_waiting_ask_return and Input.is_action_just_pressed("ui_up"):
		Rakugo.ask_return("Bob")
		
	if Rakugo.is_waiting_menu_return and Input.is_action_just_pressed("ui_down"):
		Rakugo.menu_return(1)
