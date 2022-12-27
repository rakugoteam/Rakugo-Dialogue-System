extends GutTest

const file_name = "res://Test/TestParser/TestCharacter/TestCharacter.rk"

func test_character():
	Rakugo.parse_and_execute_script(file_name)
	
	yield(yield_to(Rakugo, "execute_script_finished", 0.2), YIELD)
	
	var sylvie = Rakugo.get_character("Sy")
	
	assert_ne(sylvie, {})
	assert_eq(sylvie.get("name"), "Sylvie")
	
	var godot = Rakugo.get_character("Gd")
	
	assert_ne(godot, {})
	assert_eq(godot.get("name"), "Godot")
	
