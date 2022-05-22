extends Node

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rakugo.load_game()
	
	prints(name, "after load :", Rakugo.get_variable("hw"), Rakugo.get_variable("age"), Rakugo.get_character_variable("Sy", "name"), Rakugo.get_character_variable("Sy", "friendship"))
	
	Rakugo.set_variable("hw", "hello, world !")
	
	Rakugo.set_variable("age", 25)
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_character_variable("Sy", "friendship", 5)
	
	prints(name, "after set :", Rakugo.get_variable("hw"), Rakugo.get_variable("age"), Rakugo.get_character_variable("Sy", "name"), Rakugo.get_character_variable("Sy", "friendship"))
	
	Rakugo.save_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
