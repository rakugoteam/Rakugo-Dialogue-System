extends Dialogue

var onStep := false

var onAsk := false

func _ready():
	Rakugo.connect("step", self, "_on_step")
	Rakugo.connect("say", self, "_on_say")
	Rakugo.connect("ask", self, "_on_ask")

func _on_step():
	onStep = true

func _on_say(character, text, parameters):
	printt("say", character, text, parameters)

func _on_ask(default_answer, parameters):
	onAsk = true
	printt("ask", default_answer, parameters)

func _process(delta):
	if onStep and Input.is_action_just_pressed("ui_accept"):
		Rakugo.story_step()
		onStep = false
		
	if onAsk and Input.is_action_just_pressed("ui_down"):
		Rakugo.ask_return("Bob")
		onAsk = false

func hello_world():
	say(null, "Hello, World !")
	
	step()
	
	say(null, "What is your name ?")
	
	var name = ask("Paul")

	printt("name", name)
