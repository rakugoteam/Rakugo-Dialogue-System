extends Node

func _ready():
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("ask", self, "_on_ask")

func _on_say(character, text, parameters):
	printt("say", character, text, parameters)

func _on_step():
	printt("\nPress 'Enter' to continue...\n")

func _on_ask(default_answer, parameters):
	printt("ask", default_answer, parameters)

func _process(delta):
	if Rakugo.is_waiting_step and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
		
	if Rakugo.is_waiting_ask_return and Input.is_action_just_pressed("ui_down"):
		Rakugo.ask_return("Bob")
