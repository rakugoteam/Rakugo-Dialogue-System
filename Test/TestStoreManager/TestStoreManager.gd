extends Node

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rakugo.load_game()
	
	prints(name, "after load :", Rakugo.get_variable("hw"), Rakugo.get_variable("age"))
	
	Rakugo.set_variable("hw", "hello, world !")
	
	Rakugo.set_variable("age", 25)
	
	prints(name, "after set :", Rakugo.get_variable("hw"), Rakugo.get_variable("age"))
	
	Rakugo.define_character("Sylvie", "Sy", Color.blueviolet)
	
	Rakugo.save_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
