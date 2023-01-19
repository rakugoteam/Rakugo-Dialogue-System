extends GutTest

func get_file_base_name(file_path:String) -> String:
	return file_path.get_file().get_basename()

func watch_rakugo_signals():
	watch_signals(Rakugo)

func wait_signal(signal_name:String, parameters:Array):
	yield(yield_to(Rakugo, signal_name, 0.2), YIELD)

	assert_signal_emitted_with_parameters(
		Rakugo,
		signal_name,
		parameters)

func wait_execute_script_start(file_base_name:String):
	return wait_signal("execute_script_start", [file_base_name])

func wait_parse_and_execute_script(file_path:String):
	Rakugo.parse_and_execute_script(file_path)
	
	return wait_execute_script_start(get_file_base_name(file_path))

func wait_ask(character:Dictionary, text:String, default_answer:String):
	return wait_signal("ask", [character, text, default_answer])

func assert_ask_return(var_name:String, value):
	assert_true(Rakugo.is_waiting_ask_return())

	Rakugo.ask_return(value)
	
	assert_eq(value, Rakugo.get_variable(var_name))

func wait_execute_script_finished(file_base_name:String, error_str:String = ""):
	return wait_signal("execute_script_finished", [file_base_name, error_str])

func assert_character_name_eq(char_tag:String, value:String):
	var character = Rakugo.get_character(char_tag)

	assert_eq(character.get("name"), value)

func assert_do_step():
	assert_true(Rakugo.is_waiting_step())
	
	Rakugo.do_step()

func wait_say(character:Dictionary, text:String):
	return wait_signal("say", [character, text])

func assert_variable(var_name:String, var_type, value):
	var var_ = Rakugo.get_variable(var_name)

	assert_eq(typeof(var_), var_type)
	assert_eq(var_, value)

func wait_character_variable_changed(char_tag:String, var_name:String, var_type, value):
	yield(wait_signal("character_variable_changed", [char_tag, var_name, value]), "completed")

	assert_variable(char_tag+"."+var_name, var_type, value)

func wait_variable_changed(var_name:String, var_type, value):
	yield(wait_signal("variable_changed", [var_name, value]), "completed")

	assert_variable(var_name, var_type, value)

func wait_menu(choices:PoolStringArray):
	return wait_signal("menu", [choices])

func assert_menu_return(index:int):
	assert_true(Rakugo.is_waiting_menu_return())

	Rakugo.menu_return(index)