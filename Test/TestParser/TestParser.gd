extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const file_name = "res://Test/TestParser/Timeline.rk"

# Called when the node enters the scene tree for the first time.
func _ready():
	var parser = Parser.new()
	
	var file = File.new()
	
	if file.open(file_name, File.READ) == OK:
		var dialogues = parser.parse_script(file)
		
		file.close()
		
		for key in dialogues.keys():
			prints(key, dialogues[key])
	else:
		print("can't open file : " + file_name)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
