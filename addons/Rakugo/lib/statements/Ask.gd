extends Node

func exec(default_answer:String) -> void:
	Rakugo.emit_signal("ask", default_answer)

func return(result:String):
	Rakugo.emit_signal('ask_return', result)

#Utils functions

func _apply_default(input:Dictionary, default:Dictionary):
	var output = input.duplicate()
	for k in default.keys():
		if not output.has(k):
			output[k] = default[k]
	return output
