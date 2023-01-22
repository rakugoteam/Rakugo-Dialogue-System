extends Reference

const jump_error = "Executer::do_execute_jump, can not jump to unknow label : "

var store_manager

var stop_thread := false

var current_thread:Thread

var current_semaphore:Semaphore

var threads:Dictionary

var regex := {
	NAME = "[a-zA-Z][a-zA-Z_0-9]*",
	VARIABLE = "((?<char_tag>{NAME})\\.)?(?<var_name>{NAME})",
	VARIABLE_IN_STR = "\\<(?<variable>{VARIABLE})\\>"
}

var regex_cache := {}

var menu_jump_index:int

func _init(store_manager):
	self.store_manager = store_manager

	for key in regex:
		regex[key] = regex[key].format(regex)

	var reg := RegEx.new()
	if reg.compile(regex["VARIABLE_IN_STR"]) == OK:
		regex_cache["VARIABLE_IN_STR"] = reg
	else:
		push_error("execturer, VARIABLE_IN_STR compilation failed")

func get_current_thread_datas() -> Dictionary:
	if current_thread and current_thread.is_active():
		var dico = threads[current_thread.get_id()]

		return {"file_base_name":dico["file_base_name"], "last_index":dico["last_index"]}

	return {}

func stop_current_thread() -> int:
	if current_thread and current_thread.is_active():
		var dico = threads[current_thread.get_id()]
		
		dico["stop"] = true
		dico["semaphore"].post()
	return OK

func execute_script(script_name:String, label_name:String = "", index:int = 0) -> int:
	stop_current_thread()
	
	if store_manager.parsed_scripts.has(script_name):
		current_thread = Thread.new()
	
		current_semaphore = Semaphore.new()
		
		var dico = {"thread":current_thread, "semaphore":current_semaphore, "file_base_name":script_name, "stop":false}
	
		if index > 0:
			dico["last_index"] = index
		elif !label_name.empty():
			dico["label_name"] = label_name
	
		if current_thread.start(self, "do_execute_script", dico) != OK:
			threads.erase(current_thread.get_id())

			current_thread = null
			
			current_semaphore = null
			
			return FAILED
		return OK
	push_error("Rakugo does not have parse a script named: " + script_name)
	return FAILED

func do_execute_script_end(parameters:Dictionary):
	parameters["thread"].wait_to_finish()
	
	if parameters.has("error"):
		push_error(parameters["error"])

	if Rakugo != null:
		Rakugo.send_execute_script_finished(parameters["file_base_name"], parameters.get("error", ""))

	threads.erase(current_thread.get_id())

	current_thread = null
		
	current_semaphore = null

func do_execute_jump(jump_label:String, labels:Dictionary) -> int:
	if labels.has(jump_label):
		return labels[jump_label]

	return -1

func remove_double_quotes(s:String) -> String:
	return s.substr(1, s.length()-2)

func do_execute_script(parameters:Dictionary):
	var thread = parameters["thread"]
	
	threads[thread.get_id()] = parameters
	
	var semephore = parameters["semaphore"]
	
	var file_base_name = parameters["file_base_name"]
	
	Rakugo.send_execute_script_start(file_base_name)

	var script = store_manager.parsed_scripts[file_base_name]
	
	var parse_array:Array = script["parse_array"]
	
	var labels = script["labels"]

	var error = OK

	var index := 0

	if parameters.has("last_index"):
		index = parameters["last_index"]
	else:
		parameters["last_index"] = 0
	
		if parameters.has("label_name"):
			var label = parameters["label_name"]

			index = do_execute_jump(label, labels)
		
			if index == -1:
				parameters["error"] = jump_error + label
				parameters["stop"] = true
	
	while !parameters["stop"] and index < parse_array.size():
		parameters["last_index"] = index

		var line:Array = parse_array[index]
		
		var result = line[1]
		
		match(line[0]):
			"EXIT":
				parameters["stop"] = true
				break

			"JUMP":
				var can_jump = false

				if line.size() > 2:
					var values = []

					for var_name in line[3]:
						var var_ = Rakugo.get_variable(var_name)

						if !var_:
							parameters["error"] = "Executer::do_execute_script::JUMP, can not get variable :" + var_name
							parameters["stop"] = true
							break

						values.push_back(var_)

					can_jump = line[2].execute(values)
					
					if line[2].has_execute_failed():
						parameters["error"] = "Executer::do_execute_script::JUMP, failed to execute expression : " + result.get_string("expression")
						parameters["stop"] = true
						break
				else:
					can_jump = true

				var label = result.get_string("label")

				if can_jump:
					index = do_execute_jump(label, labels) - 1
				
				if index == -2:
					parameters["error"] = jump_error + label
					parameters["stop"] = true
					break
			
			"SAY":
				var text = remove_double_quotes(result.get_string("text"))
				
				var sub_results = regex_cache["VARIABLE_IN_STR"].search_all(text)
				
				for sub_result in sub_results:
					var var_ = Rakugo.get_variable(sub_result.get_string("variable"))
					
					if var_:
						text = text.replace(sub_result.strings[0], var_)

				Rakugo.say(result.get_string("character_tag"), text)

				Rakugo.step()

				semephore.wait()
				
			"CHARACTER_DEF":
				Rakugo.define_character(result.get_string("tag"), result.get_string("name"))
				
			"ASK":
				Rakugo.ask(result.get_string("variable"), result.get_string("character_tag"), remove_double_quotes(result.get_string("question")), remove_double_quotes(result.get_string("default_answer")))

				semephore.wait()
				
			"MENU":
				var menu_choices:PoolStringArray
				
				var menu_jumps:Dictionary
				
				for i in line[2].size():
					var menu_choice_result = line[2][i]
					
					menu_choices.push_back(remove_double_quotes(menu_choice_result.get_string("text")))
					
					var label = menu_choice_result.get_string("label")
					if !label.empty():
						menu_jumps[i] = label
				
				Rakugo.menu(menu_choices)

				semephore.wait()
				
				if menu_jumps.has(menu_jump_index):
					var jump_label = menu_jumps[menu_jump_index]

					index = do_execute_jump(jump_label, labels)
					
					if index == -1:
						parameters["error"] = jump_error + jump_label
						parameters["stop"] = true
						break

					# remove 1 because we add 1 at the end of the loop
					index -= 1	
				elif !(menu_jump_index in [0, menu_choices.size() - 1]):
					parameters["error"] = "Executer::do_execute_script::MENU, menu_jump_index out of range: " + str(menu_jump_index) + " >= " + str(menu_choices.size())
					parameters["stop"] = true
					break
		
			"SET_VARIABLE":
				var rvar_name = result.get_string("rvar_name")
				var text = result.get_string("text")
				
				var value
				
				if !rvar_name.empty():
					value = Rakugo.get_variable(rvar_name)
					
					if !value:
						parameters["error"] = "Executer::do_execute_script::SET_VARIABLE, can not get variable :" + rvar_name
						parameters["stop"] = true
						break
						
				elif !text.empty():
					value = remove_double_quotes(text)
				else:
					value = result.get_string("number")

					if value.is_valid_integer():
						value = int(value)
					else:
						value = float(value)

				Rakugo.set_variable(result.get_string("lvar_name"), value)
			_:
				Rakugo.emit_signal("parser_unhandled_regex", line[0], result)
		
		index += 1
	
	call_deferred("do_execute_script_end", parameters)
