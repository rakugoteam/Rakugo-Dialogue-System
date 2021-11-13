extends Dialogue

func _ready():
	Rakugo.connect("say", self, "_on_say")

func _on_say(character, text, parameters):
	printt(character, text, parameters)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Rakugo.story_step()

func hello_world():
	say(null, "Hello, World !")
	
	step()
	
	say(null, "What is your name ?")
	
	var name = ask("")
	
	print(name)
