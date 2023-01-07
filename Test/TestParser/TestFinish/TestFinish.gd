extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestFinish/TestFinish.rk"

var file_base_name = get_file_base_name(file_path)

func test_finish():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")

	assert_do_step()

	yield(wait_execute_script_finished(file_base_name), "completed")
