extends GutTest

func get_file_base_name(file_path:String) -> String:
	return file_path.get_file().get_basename()

func watch_rakugo_signals():
	watch_signals(Rakugo)

func wait_signal(sg:Signal, parameters:Array):
	await wait_for_signal(sg, 0.2)

	assert_signal_emitted_with_parameters(
		Rakugo,
		sg.get_name(),
		parameters)

func wait_execute_script_start(file_base_name:String):
	await wait_signal(Rakugo.sg_execute_script_start, [file_base_name])

func wait_parse_and_execute_script(file_path:String):
	Rakugo.parse_and_execute_script(file_path)
	
	await wait_execute_script_start(get_file_base_name(file_path))

func wait_ask(character:Dictionary, text:String, default_answer:String):
	await wait_signal(Rakugo.sg_ask, [character, text, default_answer])

func assert_ask_return(var_name:String, value):
	assert_true(Rakugo.is_waiting_ask_return())

	Rakugo.ask_return(value)
	
	assert_eq(value, Rakugo.get_variable(var_name))

func wait_execute_script_finished(file_base_name:String, error_str:String = ""):
	await wait_signal(Rakugo.sg_execute_script_finished, [file_base_name, error_str])

func assert_character_name_eq(char_tag:String, value:String):
	var character = Rakugo.get_character(char_tag)

	assert_eq(character.get("name"), value)

func assert_do_step():
	assert_true(Rakugo.is_waiting_step())
	
	Rakugo.do_step()

func wait_say(character:Dictionary, text:String):
	await wait_signal(Rakugo.sg_say, [character, text])

func assert_variable(var_name:String, var_type, value):
	var var_ = Rakugo.get_variable(var_name)

	assert_eq(typeof(var_), var_type)
	assert_eq(var_, value)

func wait_character_variable_changed(char_tag:String, var_name:String, var_type, value):
	await wait_signal(Rakugo.sg_character_variable_changed, [char_tag, var_name, value])

	assert_variable(char_tag+"."+var_name, var_type, value)

func wait_variable_changed(var_name:String, var_type, value):
	await wait_signal(Rakugo.sg_variable_changed, [var_name, value])

	assert_variable(var_name, var_type, value)

func wait_menu(choices:PackedStringArray):
	await wait_signal(Rakugo.sg_menu, [choices])

func assert_menu_return(index:int):
	assert_true(Rakugo.is_waiting_menu_return())

	Rakugo.menu_return(index)
