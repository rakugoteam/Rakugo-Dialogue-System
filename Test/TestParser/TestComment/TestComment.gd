extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestComment/TestComment.rk"

var file_base_name = get_file_base_name(file_path)

func test_variables():
	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	await wait_say({}, "the next line will be ignored")

	assert_do_step()

	await wait_say({}, "end")

	assert_do_step()

	await wait_execute_script_finished(file_base_name)


