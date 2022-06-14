extends GutTest

const file_name_0 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_0.rk"
const file_name_1 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_1.rk"

func before_all():
	Rakugo.connect("say", self, "_on_say")

var say_text:String
func _on_say(_character, text:String):
	say_text = text

func test_parse_and_execute():
	Rakugo.parse_and_execute_script(file_name_0)

	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_eq(say_text, "Hello, world 0 !")

	Rakugo.parse_and_execute_script(file_name_1)

	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_eq(say_text, "Hello, world 1 !")
	
	Rakugo.execute_script(file_name_1.get_file().get_basename())
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_eq(say_text, "Hello, world 1 !")
	
	Rakugo.execute_script(file_name_0.get_file().get_basename())
	
	yield(yield_to(Rakugo, "say", 0.2), YIELD)

	assert_eq(say_text, "Hello, world 0 !")
