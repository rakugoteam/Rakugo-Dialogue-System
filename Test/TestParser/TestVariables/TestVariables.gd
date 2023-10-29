extends "res://Test/RakugoTest.gd"

func test_variables():
	var file_path = "res://Test/TestParser/TestVariables/TestVariables.rk"

	var file_base_name = get_file_base_name(file_path)

	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	var error_str = "Executer::do_execute_script::SET_VARIABLE, Cannot resolve assignement: f of type(2) += with type(4)"

	await wait_execute_script_finished(file_base_name, error_str)

	assert_variable("a", TYPE_INT, 1)

	assert_variable("b", TYPE_FLOAT, 3.5)

	assert_variable("c", TYPE_STRING, "Hello, world !")

	assert_variable("d", TYPE_INT, -1)

	assert_variable("Sy.name", TYPE_STRING, "Sylvie")
	
	assert_variable("e", TYPE_INT, Rakugo.get_variable("Sy.life"))
	
	assert_variable("Sy.life", TYPE_INT, 10)

	assert_eq(Rakugo.get_variable("g"), null)

func  test_variables_in_strings():
	var file_path = "res://Test/TestParser/TestVariables/TestDynamicVars.rk"

	var file_base_name = get_file_base_name(file_path)

	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	assert_variable("test_var", TYPE_STRING, "c")

	assert_variable("test_var_b", TYPE_STRING, "cb")

	await wait_execute_script_finished(file_base_name)
