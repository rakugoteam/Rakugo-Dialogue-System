extends Node

const file_name = "res://Test/TestParser/Timeline.rk"

onready var label = $RichTextLabel
onready var line_edit = $LineEdit
onready var menu_container = $MenuContainer

func _ready():
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("ask", self, "_on_ask")
	Rakugo.connect("menu", self, "_on_menu")
	Rakugo.connect("notify", self, "_on_notify")
	
	Rakugo.parse_script(file_name)

func _on_say(character:Character, text:String):
#	prints("TestGui", "say", character.name if character else "null", text)
	label.clear()
	label.add_text(text)

func _on_step():
	label.add_text("\nPress 'Enter' to continue...")

func _on_ask(character:Character, question:String, default_answer:String):
#	prints("TestGui", "ask", character.name if character else "null", question, default_answer)
	label.clear()
	label.add_text(question)
	
	line_edit.visible = true
	line_edit.text = default_answer
	
func _on_menu(choices):
	label.visible = false
	
#	prints("TestGui", "menu", choices)
	for node in menu_container.get_children():
		node.queue_free()
		
	for choice in choices:
		var button = Button.new()
		button.text = choice
		button.connect("pressed", self, "_on_menu_button_pressed", [button])
		menu_container.add_child(button)
		
	menu_container.visible = true
	
func _on_notify(text:String):
	printt("notify", text)

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()

func _on_LineEdit_text_entered(new_text: String) -> void:
	Rakugo.ask_return(new_text)
	line_edit.visible = false

func _on_menu_button_pressed(button:Button):
	Rakugo.menu_return(button.get_index())
	
	menu_container.visible = false
	
	label.visible = true
