extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestSay/TestSay.rk"

var file_base_name = get_file_base_name(file_path)

func test_say():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_say({}, "Hello, world !"), "completed")

	assert_do_step()
	
	yield(wait_say({"name": "Sylvie"}, "Hello !"), "completed")

	assert_do_step()

	yield(wait_say({}, "My name is Sylvie"), "completed")
	
	assert_do_step()
	
	yield(wait_say({}, "I am 18"), "completed")
	
	assert_do_step()

	yield(wait_execute_script_finished(file_base_name), "completed")