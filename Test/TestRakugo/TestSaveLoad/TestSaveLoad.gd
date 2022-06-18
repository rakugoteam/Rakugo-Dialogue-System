extends GutTest

func before_all():
	var save_folder = "user://saves/quick"
	
	var directory = Directory.new()
	
	if directory.dir_exists(save_folder):
		var save_path = save_folder + "/save.json"
		
		if directory.file_exists(save_path):
			directory.remove(save_path)
			
		directory.remove(save_folder)

func test_save_load():
	Rakugo.set_variable("life", 5)
	
	Rakugo.define_character("Sy", "Sylvie")
	
	Rakugo.set_variable("Sy.friendship", 3)
	
	Rakugo.save_game()
	
	Rakugo.load_game()
	
	assert_eq(Rakugo.get_variable("life"), 5)

	assert_eq(Rakugo.get_variable("Sy.friendship"), 3)
	
	pass
