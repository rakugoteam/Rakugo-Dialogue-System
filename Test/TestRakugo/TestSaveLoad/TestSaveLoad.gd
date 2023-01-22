extends "res://Test/RakugoTest.gd"

const file_path = "res://Test/TestRakugo/TestSaveLoad/TestSaveLoad.rk"

var file_base_name = get_file_base_name(file_path)

func before_all():
	var save_folder = ProjectSettings.get_setting("addons/rakugo/save_folder")
	
	var directory = Directory.new()
	
	if directory.dir_exists(save_folder):
		var save_path = save_folder + "/save.json"
		
		if directory.file_exists(save_path):
			directory.remove(save_path)
			
		directory.remove(save_folder)

func test_save_load():
	watch_rakugo_signals()

	Rakugo.set_variable("life", 5)

	wait_variable_changed("life", TYPE_INT, 5)
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_variable("Sy.friendship", 3)

	wait_character_variable_changed("Sy", "friendship", TYPE_INT, 3)

	yield(wait_parse_and_execute_script(file_path), "completed")

	yield(wait_say({}, "Hello, world !"), "completed")

	assert_do_step()

	yield(wait_say({}, "Save from here"), "completed")
	
	Rakugo.save_game()

	Rakugo.stop_last_script()

	yield(wait_execute_script_finished(file_base_name), "completed")
	
	Rakugo.load_game()

	Rakugo.resume_loaded_script()

	yield(wait_execute_script_start(file_base_name), "completed")

	yield(wait_say({}, "Save from here"), "completed")

	Rakugo.stop_last_script()

	yield(wait_execute_script_finished(file_base_name), "completed")
	
	assert_eq(Rakugo.get_variable("life"), 5)

	assert_eq(Rakugo.get_variable("Sy.friendship"), 3)
	
	pass
