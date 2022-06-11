extends GutTest

const file_name = "res://Test/TestParser/TestJumpIf/TestJumpIf.rk"

func before_all():
	Rakugo.connect("say", self, "_on_say")
	
	Rakugo.parse_script(file_name)

var say_char:Dictionary
var say_text:String
func _on_say(character:Dictionary, text:String):
	say_char = character
	say_text = text

func test_jump_if():
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_true(say_char.empty())
	assert_eq(say_text, "no jump")
	
	Rakugo.do_step()
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_true(say_char.empty())
	assert_eq(say_text, "jump")
	
	Rakugo.do_step()
