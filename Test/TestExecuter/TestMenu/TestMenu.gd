extends "res://Test/RakugoTest.gd"

func test_menu():
	var file_path = "res://Test/TestExecuter/TestMenu/TestMenu.rk"

	var file_base_name = get_file_base_name(file_path)

	watch_rakugo_signals()
	
	await wait_parse_and_execute_script(file_path)
	
	await wait_menu(["Loop0", "End", "Loop1"])

	assert_menu_return(0);
	
	await wait_menu(["Loop0", "End", "Loop1"])
		
	assert_menu_return(1);

	await wait_execute_script_finished(file_base_name)

func test_menu_out_of_range():
	var file_path = "res://Test/TestExecuter/TestMenu/TestMenu.rk"

	var file_base_name = get_file_base_name(file_path)

	watch_rakugo_signals()
	
	await wait_parse_and_execute_script(file_path)
	
	await wait_menu(["Loop0", "End", "Loop1"])

	assert_menu_return(3);

	await wait_execute_script_finished(file_base_name, "Executer::do_execute_script::MENU, menu_jump_index out of range: 3 >= 3")
