extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestAsk/TestAsk.rk"

var file_base_name = get_file_base_name(file_path)

func test_ask():
	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)
	
	await wait_ask({}, "Are you human ?", "Yes")
	
	assert_ask_return("answer", "No")
	
	await wait_execute_script_finished(file_base_name)
