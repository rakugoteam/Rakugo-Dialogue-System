extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestParser/TestCharacter/TestCharacter.rk"

var file_base_name = get_file_base_name(file_path)

func test_character():
	watch_rakugo_signals()

	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_execute_script_finished(file_base_name), "completed")
	
	assert_character_name_eq("Sy", "Sylvie")

	assert_character_name_eq("Gd", "Godot")
	
