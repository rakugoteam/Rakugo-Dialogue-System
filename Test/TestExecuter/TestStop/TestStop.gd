extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestExecuter/TestStop/TestStop.rk"

var file_base_name = get_file_base_name(file_path)

func test_stop():
	watch_rakugo_signals()
	
	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_say({}, "You can see this message"), "completed")

	Rakugo.stop_last_script()

	yield(wait_execute_script_finished(file_base_name), "completed")