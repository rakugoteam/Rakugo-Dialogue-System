extends RakuScriptDialogue

func _ready():
	Rakugo.sg_say.connect(_on_say)
	super._ready()

func _on_say(character: Dictionary, text: String):
	print(character.name, " : ", text)
	Rakugo.step()

