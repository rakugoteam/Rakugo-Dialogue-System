extends "res://Test/RakugoTest.gd"

const file_path = "res://test/TestParser/TestAsk/TestAsk.rk"

var file_base_name = get_file_base_name(file_path)

func test_ask():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")
	
	yield(wait_ask({}, "Are you human ?", "Yes"), "completed")
	
	assert_ask_return("answer", "No")
	
	yield(wait_execute_script_finished(file_base_name), "completed")
