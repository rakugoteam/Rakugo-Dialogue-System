#extends GutTest
#
#const file_name_0 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_0.rk"
#const file_name_1 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_1.rk"
#const file_name_2 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_2.rk"
#
#func before_all():
#	Rakugo.connect("say", self, "_on_say")
#
#var say_text:String
#func _on_say(character_, text:String):
#	prints(name, text)
#	say_text = text
#
#func test_parse_and_execute():
#	Rakugo.parse_and_execute_script(file_name_0)
#
#	yield(Rakugo, "say")
#
#	assert_eq(say_text, "Hello, world 0 !")
#
#	Rakugo.do_step()
#
#
#
#	Rakugo.parse_and_execute_script(file_name_1)
#
#	yield(Rakugo, "say")
#
#	assert_eq(say_text, "Hello, world 1 !")
#
#	Rakugo.do_step()

extends Node

const file_name_0 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_0.rk"
const file_name_1 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_1.rk"
const file_name_2 = "res://Test/TestParser/TestParseAndExecute/TestParseAndExecute_2.rk"

func _ready() -> void:
	Rakugo.parse_and_execute_script(file_name_0)

	yield(Rakugo, "say")

	Rakugo.parse_and_execute_script(file_name_1)
#
#	yield(Rakugo, "say")
#
#	Rakugo.do_step()
