extends GutTest

const file_path = "res://Test/TestParser/TestStartFromLabel/TestStartFromLabel.rk"

var say_char:Dictionary
var say_text:String
func _on_say(character:Dictionary, text:String):
	say_char = character
	say_text = text

func test_start_from_label():
	Rakugo.connect("say", self, "_on_say")
	
	Rakugo.parse_and_execute_script(file_path, "pictures")
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_eq(say_text, "Pictures of places that I have visited.")
