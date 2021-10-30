extends Node

var default_parameters = {}

func _ready():
	default_parameters = Settings.get(SettingsList.default_menu_parameters, {}, false)

func exec(choices:Array, parameters = {}) -> void:
	var id := -1
	for choice in choices:
		id += 1
		if choice is String:
			choices[id] = [choice]
			choice = choices[id]
		
		if choice.size() == 1:
			choice.append(choice[0])
			
		if choice.size() == 2:
			choice.append({})

	parameters = _apply_default(parameters, default_parameters)
	Rakugo.StepBlocker.block('menu')
	Rakugo.emit_signal("menu", choices, parameters)

func return(result):
	Rakugo.emit_signal('menu_return', result)
	Rakugo.StepBlocker.unblock('menu')

#Utils functions
func _apply_default(input:Dictionary, default:Dictionary):
	var output = input.duplicate()
	for k in default.keys():
		if not output.has(k):
			output[k] = default[k]
			
	return output
