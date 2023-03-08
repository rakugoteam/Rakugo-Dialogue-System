extends Node

const file_path = "res://Test/TestReadmeExample/TestReadmeExample.rk"

func _ready():
	Rakugo.sg_say.connect(_on_say)
	Rakugo.sg_step.connect(_on_step)
	Rakugo.sg_execute_script_finished.connect(_on_execute_script_finished)
  
	Rakugo.parse_and_execute_script(file_path)
  
func _on_say(character:Dictionary, text:String):
	prints("Say", character.get("name", ""), text)
  
func _on_step():
	prints("Press \"Enter\" to continue...")
	
func _on_execute_script_finished(_file_name:String, _error_str:String):
	prints("End of script")
  
func _process(_delta):
	if Rakugo.is_waiting_step() and Input.is_action_just_pressed("ui_accept"):
		Rakugo.do_step()
