extends "res://Test/RakugoTest.gd"

const file_path = "res://test/TestParser/TestMenu/TestMenu.rk"

var file_base_name = get_file_base_name(file_path)

func test_menu():
	watch_rakugo_signals()
	
	yield(wait_parse_and_execute_script(file_path), "completed")
	
	yield(wait_menu(["Loop", "End"]), "completed")

	assert_menu_return(0);
	
	yield(wait_menu(["Loop", "End"]), "completed")
		
	assert_menu_return(1);

	yield(wait_execute_script_finished(file_base_name), "completed")
