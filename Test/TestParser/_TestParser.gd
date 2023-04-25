extends Node

const file_name = "res://Test/TestParser/Timeline.rk"

# Called when the node enters the scene tree for the first time.
func _ready():
	Rakugo.parser_add_regex_at_runtime("HW", "^hello_world$")
	
	Rakugo.connect("parser_unhandled_regex",Callable(self,"_on_parser_unhandled_regex"))
	Rakugo.connect("say",Callable(self,"_on_say"))
	Rakugo.connect("sg_step",Callable(self,"_on_step"))
	Rakugo.connect("ask",Callable(self,"_on_ask"))
	Rakugo.connect("menu",Callable(self,"_on_menu"))
	
	Rakugo.parse_script(file_name)

func _on_say(character:Dictionary, text:String):
	prints("TestParser", "say", character.get("name", "null"), text)

func _on_step():
	prints("TestParser", "\nPress 'Enter' to continue...\n")
	
func _on_ask(character:Dictionary, question:String, default_answer:String):
	prints("TestParser", "ask", character.get("name", "null"), question, default_answer)

func _on_menu(choices):
	prints("TestParser", "menu", choices)
	
func _on_parser_unhandled_regex(key:String, result:RegExMatch):
	match(key):
		"HW":
			prints(name, "regex hello, world !")

func _process(delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
		
	if Rakugo.is_waiting_ask_return() and Input.is_action_just_pressed("ui_up"):
		Rakugo.ask_return("Bob")
		prints(name, "ask_return answer", Rakugo.get_variable("answer"))
		
	if Rakugo.is_waiting_menu_return() and Input.is_action_just_pressed("ui_down"):
		Rakugo.menu_return(0)
