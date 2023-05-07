extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestRakugo/TestSaveLoad/TestSaveLoad.rk"

var file_base_name = get_file_base_name(file_path)

func before_all():
	var save_folder = ProjectSettings.get_setting("addons/rakugo/save_folder")
	
	if DirAccess.dir_exists_absolute(save_folder):
		var save_path = save_folder + "/save.json"
		
		if FileAccess.file_exists(save_path):
			DirAccess.remove_absolute(save_path)
			
		DirAccess.remove_absolute(save_folder)

func test_save_load():
	watch_rakugo_signals()

	Rakugo.set_variable("life", 5)

	wait_variable_changed("life", TYPE_INT, 5)
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_variable("Sy.friendship", 3)

	wait_character_variable_changed("Sy", "friendship", TYPE_INT, 3)

	await wait_parse_and_execute_script(file_path)

	await wait_say({}, "Hello, world !")

	assert_do_step()

	await wait_say({}, "Save from here")
	
	Rakugo.save_game()

	Rakugo.stop_last_script()

	await wait_execute_script_finished(file_base_name)
	
	Rakugo.load_game()
	
	await wait_signal(Rakugo.sg_game_loaded, [])

	Rakugo.resume_loaded_script()

	await wait_execute_script_start(file_base_name)

	await wait_say({}, "Save from here")

	Rakugo.stop_last_script()

	await wait_execute_script_finished(file_base_name)
	
	assert_eq(Rakugo.get_variable("life"), 5)

	assert_eq(Rakugo.get_variable("Sy.friendship"), 3)
	
	pass
