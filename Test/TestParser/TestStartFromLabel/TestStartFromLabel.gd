extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestStartFromLabel/TestStartFromLabel.rk"

var file_base_name = get_file_base_name(file_path)

func test_start_from_label():
	Rakugo.parse_and_execute_script(file_path, "pictures")

	yield(wait_execute_script_start(file_base_name), "completed")

	yield(wait_say({}, "Pictures of places that I have visited."), "completed")

	assert_do_step()

	yield(wait_execute_script_finished(file_base_name), "completed")
