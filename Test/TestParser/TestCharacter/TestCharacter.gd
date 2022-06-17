extends GutTest

const file_name = "res://Test/TestParser/TestCharacter/TestCharacter.rk"

func before_all():
	Rakugo.parse_and_execute_script(file_name)

func test_character():
	var sylvie = Rakugo.get_character("Sy")
	
	assert_ne(sylvie, {})
	assert_eq(sylvie.get("name"), "Sylvie")
	
	var godot = Rakugo.get_character("Gd")
	
	assert_ne(godot, {})
	assert_eq(godot.get("name"), "Godot")
	
