extends RefCounted

const jump_error = "Executer::do_execute_jump, can not jump to unknow label : "

var stop_thread := false

var current_thread: Thread

var current_semaphore: Semaphore

var threads: Dictionary

var regex := {
	NAME = "[a-zA-Z][a-zA-Z_0-9]*",
	VARIABLE = "((?<char_tag>{NAME})\\.)?(?<var_name>{NAME})",
	VARIABLE_IN_STR = "\\<(?<variable>{VARIABLE})\\>"
}

var regex_cache := {}

var menu_jump_index: int

func _init():
	for key in regex:
		regex[key] = regex[key].format(regex)

	var reg := RegEx.new()
	if reg.compile(regex["VARIABLE_IN_STR"]) == OK:
		regex_cache["VARIABLE_IN_STR"] = reg
	else:
		push_error("execturer, VARIABLE_IN_STR compilation failed")

func get_current_thread_datas() -> Dictionary:
	if current_thread:
		var dico = threads[current_thread.get_id()]

		return {"file_base_name": dico["file_base_name"], "last_index": dico["last_index"]}

	return {}

func stop_current_thread() -> int:
	if current_thread and current_thread.is_alive():
		var dico = threads[current_thread.get_id()]
		
		dico["stop"] = true
		dico["semaphore"].post()
	return OK

func execute_script(parsed_script: Dictionary, label_name: String = "", index: int = 0) -> int:
	stop_current_thread()

	current_thread = Thread.new()

	current_semaphore = Semaphore.new()
	
	var thread_parameters = {
		"thread": current_thread,
		"semaphore": current_semaphore,
		"parsed_script": parsed_script,
		"file_base_name": parsed_script["path"].get_file().get_basename(),
		"stop": false
		}

	if index > 0:
		thread_parameters["last_index"] = index
	elif !label_name.is_empty():
		thread_parameters["label_name"] = label_name

	if current_thread.start(Callable(self, "do_execute_script").bind(thread_parameters)) != OK:
		threads.erase(current_thread.get_id())

		current_thread = null
		
		current_semaphore = null
		
		return FAILED
	return OK

func do_execute_script_end(parameters: Dictionary):
	parameters["thread"].wait_to_finish()
	
	if parameters.has("error"):
		push_error(parameters["error"])

	if Rakugo != null:
		Rakugo.call_thread_safe("send_execute_script_finished", parameters["file_base_name"], parameters.get("error", ""))

	threads.erase(current_thread.get_id())

	current_thread = null
		
	current_semaphore = null

func do_execute_jump(jump_label: String, labels: Dictionary) -> int:
	if labels.has(jump_label):
		return labels[jump_label]

	return -1

func do_execute_script(parameters: Dictionary):
	var thread = parameters["thread"]
	
	threads[thread.get_id()] = parameters
	
	var semephore = parameters["semaphore"]
	
	var parsed_script = parameters["parsed_script"]
	
	Rakugo.call_thread_safe("send_execute_script_start", parameters["file_base_name"])
	
	var parse_array: Array = parsed_script["parse_array"]
	
	var labels = parsed_script["labels"]

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

		var line: Array = parse_array[index]
		
		var result = line[1]
		
		match (line[0]):
			"EXIT":
				parameters["stop"] = true
				break

			"JUMP":
				var can_jump = false

				if line.size() > 2:
					var values = []

					for var_name in line[3]:
						var var_ = Rakugo.get_variable(var_name)

						if var_ == null:
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
				var text = Rakugo.replace_variables(result["text"])

				Rakugo.call_thread_safe("say", result["character_tag"], text)
				
				Rakugo.call_thread_safe("step")

				semephore.wait()
				
			"CHARACTER_DEF":
				Rakugo.define_character(result.get_string("tag"), result.get_string("name"))
				
			"ASK":
				Rakugo.call_thread_safe("ask",
					result["variable"],
					result["character_tag"],
					Rakugo.replace_variables(result["question"]),
					Rakugo.replace_variables(result["default_answer"])
				)

				semephore.wait()
				
			"MENU":
				var menu_choices: PackedStringArray
				
				var menu_jumps: Dictionary
				
				for i in line[2].size():
					var menu_choice_result = line[2][i]
					
					menu_choices.push_back(
						Rakugo.replace_variables(menu_choice_result["text"])
					)
					
					var label = menu_choice_result["label"]
					if !label.is_empty():
						menu_jumps[i] = label
				
				Rakugo.call_thread_safe("menu", menu_choices)

				semephore.wait()
				
				if menu_jump_index < 0 or menu_jump_index >= menu_choices.size():
					parameters["error"] = "Executer::do_execute_script::MENU, menu_jump_index out of range: " + str(menu_jump_index) + " >= " + str(menu_choices.size())
					parameters["stop"] = true
					break
				
				if menu_jumps.has(menu_jump_index):
					var jump_label = menu_jumps[menu_jump_index]

					index = do_execute_jump(jump_label, labels)
					
					if index == -1:
						parameters["error"] = jump_error + jump_label
						parameters["stop"] = true
						break

					# remove 1 because we add 1 at the end of the loop
					index -= 1
					
			"SET_VARIABLE":
				var rvar_name = result["rvar_name"]
				var text = result["text"]
				
				var value = null
				
				if !rvar_name.is_empty():
					value = Rakugo.get_variable(rvar_name)

					if value == null:
						parameters["error"] = "Executer::do_execute_script::SET_VARIABLE, can not get variable :" + rvar_name
						parameters["stop"] = true
						break
				
				elif !result["bool"].is_empty():
					value = result["bool"] == "true"
				elif !text.is_empty():
					value = text
				else:
					value = result["number"]

					if value.is_valid_int():
						value = int(value)
					else:
						value = float(value)

				var assignment = result["assignment"]
				
				var lvar_name = result["lvar_name"]
				
				if assignment != "=":
					var lvalue = Rakugo.get_variable(lvar_name)
					
					if lvalue == null:
						parameters["error"] = "Executer::do_execute_script::SET_VARIABLE, Rakugo does not knew a variable called: " + lvar_name
						parameters["stop"] = true
						break
					
					var lvalue_type = typeof(lvalue)
					var value_type = typeof(value)
					
					# required because the thread crash (not godot) without error
					# we only accept string and numbers when we parse
					if value_type == TYPE_STRING and lvalue_type != TYPE_STRING:
						parameters["error"] = "Executer::do_execute_script::SET_VARIABLE, Cannot resolve assignement: " + lvar_name + " of type(" + str(lvalue_type) + ") " + assignment + " with type(" + str(value_type) + ")"
						parameters["stop"] = true
						break
					
					match (assignment):
						"+=":
							value = lvalue + value
							
						"-=":
							value = lvalue - value
							
						"*=":
							value = lvalue * value
							
						"/=":
							value = lvalue / value
						
						_:
							parameters["error"] = "Executer::do_execute_script::SET_VARIABLE, the assignment operator is not implemented :" + assignment
							parameters["stop"] = true
							break

				Rakugo.set_variable(lvar_name, value)
			_:
				var foo = func():
					Rakugo.sg_custom_regex.emit(line[0], result)
				
				foo.call_deferred()
		
		index += 1
	
	call_deferred("do_execute_script_end", parameters)
