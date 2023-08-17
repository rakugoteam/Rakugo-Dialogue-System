extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestExecuter/TestSay/TestSay.rk"

var file_base_name = get_file_base_name(file_path)

func test_say():
	watch_rakugo_signals()

	await wait_parse_and_execute_script(file_path)

	await wait_say({}, "Hello, world !")

	assert_do_step()
	
	await wait_say({"name": "Sylvie"}, "Hello !")

	assert_do_step()

	await wait_say({}, "My name is Sylvie")
	
	assert_do_step()
	
	await wait_say({}, "I am 18")
	
	assert_do_step()

	await wait_execute_script_finished(file_base_name)
