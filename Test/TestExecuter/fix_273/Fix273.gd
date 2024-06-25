extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestExecuter/fix_273/fix273.rk"

var file_base_name = get_file_base_name(file_path)

func test_273_fix():
	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	await assert_variable("test_var", TYPE_INT, 0)

	await wait_say({}, "273 fixed")

	assert_do_step()

	await wait_execute_script_finished(file_base_name)

