extends Node

func exec(choices:Array) -> void:
	Rakugo.emit_signal("menu", choices)

func return(result):
	Rakugo.emit_signal('menu_return', result)

#Utils functions
func _apply_default(input:Dictionary, default:Dictionary):
	var output = input.duplicate()
	for k in default.keys():
		if not output.has(k):
			output[k] = default[k]
			
	return output
