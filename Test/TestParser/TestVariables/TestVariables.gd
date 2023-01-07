extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestVariables/TestVariables.rk"

var file_base_name = get_file_base_name(file_path)

func test_variables():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_execute_script_finished(file_base_name), "completed")

	assert_variable("aaa", TYPE_INT, 1)

	assert_variable("bbb", TYPE_REAL, 2.5)

	assert_variable("ccc", TYPE_STRING, "Hello, world !")

	assert_variable("ddd", TYPE_INT, Rakugo.get_variable("aaa"))

	assert_variable("Sy.name", TYPE_STRING, "Sylvie")
	
	assert_variable("Sy.life", TYPE_INT, 5)
	
	assert_variable("eee", TYPE_INT, Rakugo.get_variable("Sy.life"))

	assert_eq(Rakugo.get_variable("fff"), null)
