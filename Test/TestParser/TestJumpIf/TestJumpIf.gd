extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestJumpIf/TestJumpIf.rk"

var file_base_name = get_file_base_name(file_path)

func test_jump_if():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_character_variable_changed("test_ch", "ax", TYPE_INT, 2), "completed")

	yield(wait_variable_changed("ax", TYPE_INT, 2), "completed")

	yield(wait_say({}, "no jump"), "completed")
	
	assert_do_step()
	
	yield(wait_say({}, "jump"), "completed")

	assert_do_step()

	yield(wait_execute_script_finished(file_base_name), "completed")
