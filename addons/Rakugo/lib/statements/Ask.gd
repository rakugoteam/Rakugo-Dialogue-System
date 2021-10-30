extends Node

var default_parameters = {}

func _ready():
	default_parameters = Settings.get(SettingsList.default_ask_parameters, {}, false)

func exec(default_answer:String, parameters = {}) -> void:
	parameters = _apply_default(parameters, default_parameters)

	Rakugo.StepBlocker.block('ask')
	Rakugo.emit_signal("ask", default_answer, parameters)


func return(result):
	Rakugo.emit_signal('ask_return', result)
	Rakugo.StepBlocker.unblock('ask')

#Utils functions

func _apply_default(input:Dictionary, default:Dictionary):
	var output = input.duplicate()
	for k in default.keys():
		if not output.has(k):
			output[k] = default[k]
	return output
