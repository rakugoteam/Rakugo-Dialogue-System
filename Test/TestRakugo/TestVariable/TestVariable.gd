extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rakugo.set_variable("a", 1)
	
	var a = Rakugo.get_variable("a")
	
	if a == 1:
		prints("Success")
	else:
		prints("Failed")
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_variable("Sy.a", 1)
	
	var sya = Rakugo.get_variable("Sy.a")
	
	if sya == 1:
		prints("Success")
	else:
		prints("Failed")
		
	Rakugo.get_variable("b")
	
	Rakugo.get_variable("Bob.a")
	
	Rakugo.get_variable("Sy.b")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
