extends GutTest

const Parser = preload("res://addons/Rakugo/lib/systems/Parser.gd")

@onready var parser := Parser.new()

var test_params = [
	["\"Hello, world !\""],
	["	\"Hello, world !\""],
	["  \"Hello, world !\""],
	["\"Hello, world !\" "]
]

func test_say(params=use_parameters(test_params)):
	var parsed_script = parser.parse_script(params)
	
	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())
	
	assert_true(parsed_script.get("labels", [""]).is_empty())

	assert_true(parsed_array[0][0] == "SAY")

	var result = parsed_array[0][1]
	
	assert_eq(result["text"], "Hello, world !")

func test_say_character():
	var rk_script = [
		"sy \"Hello !\""
	]

	var parsed_script = parser.parse_script(rk_script)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())
	
	assert_true(parsed_script.get("labels", [""]).is_empty())

	assert_true(parsed_array[0][0] == "SAY")

	var result = parsed_array[0][1]

	assert_eq(result["character_tag"], "sy")
	
	assert_eq(result["text"], "Hello !")

func test_say_variable():
	var rk_script = [
		"\"My name is <sy.name>\""
	]

	var parsed_script = parser.parse_script(rk_script)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())
	
	assert_true(parsed_script.get("labels", [""]).is_empty())

	assert_true(parsed_array[0][0] == "SAY")

	var result = parsed_array[0][1]
	
	assert_eq(result["text"], "My name is <sy.name>")
	
func test_say_escape_characters():
	var rk_script = [
		"\"first\\nsecond\\n\\nthird\"",
		"\"\\ttabulation\\t\\ttabulations\""
	]

	var parsed_script = parser.parse_script(rk_script)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())
	
	assert_true(parsed_script.get("labels", [""]).is_empty())

	assert_true(parsed_array[0][0] == "SAY")

	var result = parsed_array[0][1]
	
	assert_eq(result["text"], "first\nsecond\n\nthird")
	
	result = parsed_array[1][1]
	
	assert_eq(result["text"], "\ttabulation\t\ttabulations")
