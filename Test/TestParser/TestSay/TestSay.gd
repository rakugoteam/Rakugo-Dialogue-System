extends GutTest

const file_name = "res://Test/TestParser/TestSay/TestSay.rk"

func before_all():
	Rakugo.connect("say", self, "_on_say")
	
	Rakugo.parse_and_execute_script(file_name)
	
var say_char:Dictionary
var say_text:String
func _on_say(character:Dictionary, text:String):
	say_char = character
	say_text = text

func test_say():
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_true(say_char.empty())
	assert_eq(say_text, "Hello, world !")
	
	Rakugo.do_step()
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_false(say_char.empty())
	assert_eq(say_char["name"], "Sylvie")
	assert_eq(say_text, "Hello !")
	
	Rakugo.do_step()
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_eq(say_text, "My name is Sylvie")
	
	Rakugo.do_step()
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)
	
	assert_eq(say_text, "I am 18")
	
	Rakugo.do_step()
