extends Node
class_name RakuScriptDialogue

export(String, FILE, "*.rk") var raku_script : String

var parser:Parser

func _ready():
  parser = Parser.new()
  Rakugo.current_parser = parser
  parser.parse_script(raku_script)

func _exit_tree():
	var thread = parser.thread
	
	if thread:
		parser.stop_thread = true
		parser.step_semaphore.post()
		thread.wait_to_finish()
