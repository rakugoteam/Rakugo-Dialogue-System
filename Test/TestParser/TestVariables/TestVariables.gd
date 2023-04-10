extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestVariables/TestVariables.rk"

var file_base_name = get_file_base_name(file_path)

func test_variables():
	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	await wait_execute_script_finished(file_base_name)

	assert_variable("a", TYPE_INT, 1)

	assert_variable("b", TYPE_FLOAT, 2.5)

	assert_variable("c", TYPE_STRING, "Hello, world !")

	assert_variable("d", TYPE_INT, Rakugo.get_variable("a"))

	assert_variable("Sy.name", TYPE_STRING, "Sylvie")
	
	assert_variable("Sy.life", TYPE_INT, 5)
	
	assert_variable("e", TYPE_INT, Rakugo.get_variable("Sy.life"))

	assert_eq(Rakugo.get_variable("f"), null)
