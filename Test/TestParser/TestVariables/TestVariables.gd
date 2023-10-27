extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestVariables/TestVariables.rk"

var file_base_name = get_file_base_name(file_path)

func test_variables():
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
