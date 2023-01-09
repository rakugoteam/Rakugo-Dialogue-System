extends Object

var store_manager

var stop_thread := false

var current_thread:Thread

var current_semaphore:Semaphore

var threads:Dictionary

var regex := {
	NAME = "[a-zA-Z_][a-zA-Z_0-9]+",
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

func close() -> int:
	if current_thread and current_thread.is_active():
		var dico = threads[current_thread.get_id()]
		
		dico["stop"] = true
		dico["semaphore"].post()
	return OK

func execute_script(script_name:String, label_name:String) -> int:
	close()
	
	if store_manager.parsed_scripts.has(script_name):
		current_thread = Thread.new()
	
		current_semaphore = Semaphore.new()
		
		var dico = {"thread":current_thread, "semaphore":current_semaphore, "file_base_name":script_name, "stop":false}
	
		if !label_name.empty():
			dico["label_name"] = label_name
	
		if current_thread.start(self, "do_execute_script", dico) != OK:
			current_thread = null
			
			current_semaphore = null
			
			threads.erase(current_thread.get_id())
			
			return FAILED
		return OK
	push_error("Rakugo does not have parse a script named: " + script_name)
	return FAILED

func do_execute_script_end(thread:Thread, file_base_name:String):
	thread.wait_to_finish()
	
	if Rakugo != null:
		Rakugo.send_execute_script_finished(file_base_name)

func do_execute_jump(jump_label:String, parse_array:Array, labels:Dictionary) -> int:
	if labels.has(jump_label):
		return labels[jump_label]
		
	push_error("Parser, do_execute_script, JUMP, unknow label")
	return -1

func remove_double_quotes(s:String) -> String:
	return s.substr(1, s.length()-2)

func do_execute_script(parameters:Dictionary):
	var thread = parameters["thread"]
	
	threads[thread.get_id()] = parameters
	
	var semephore = parameters["semaphore"]
	
	var file_base_name = parameters["file_base_name"]
	
	Rakugo.send_execute_script_start(file_base_name)
	
	var index := 0

	var script = store_manager.parsed_scripts[file_base_name]
	
	var parse_array:Array = script["parse_array"]
	
	var labels = script["labels"]
	
	if parameters.has("label_name"):
		index = do_execute_jump(parameters["label_name"], parse_array, labels)
		
		if index == -1:
			return
	
	while !parameters["stop"] and index < parse_array.size():
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
							push_error("Execute: Error on line: " + str(index))
							parameters["stop"] = true
							break

						values.push_back(var_)

					can_jump = line[2].execute(values)
					
					if line[2].has_execute_failed():
						push_error("Execute: Error on line: " + str(index))
						parameters["stop"] = true
						break
				else:
					can_jump = true

				if can_jump:
					index = do_execute_jump(result.get_string("label"), parse_array, labels) - 1
				
				if index == -2:
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

					index = do_execute_jump(jump_label, parse_array, labels) - 1
					
					if index == -2:
						parameters["stop"] = true
						break
				elif !(menu_jump_index in [0, menu_choices.size() - 1]):
					push_error("Parser, do_execute_script, MENU, menu_jump_index out of range: " + str(menu_jump_index) + " >= " + str(menu_choices.size()) )
					parameters["stop"] = true
					break
		
			"SET_VARIABLE":
				var rvar_name = result.get_string("rvar_name")
				var text = result.get_string("text")
				
				var value
				
				if !rvar_name.empty():
					value = Rakugo.get_variable(rvar_name)
					
					if !value:
						push_error("Parser::do_execute_script::SET_VARIABLE, variable " + rvar_name + " does not exist !")
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
	
	call_deferred("do_execute_script_end", thread, file_base_name)
