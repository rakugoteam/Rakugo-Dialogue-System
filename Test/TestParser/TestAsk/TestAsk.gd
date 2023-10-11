extends GutTest

const Parser = preload("res://addons/Rakugo/lib/systems/Parser.gd")

@onready var parser := Parser.new()

var test_ask_params = [
	["answer=?\"Hello ?\""],
	["answer = ? \"Hello ?\""]
]

func test_ask(params=use_parameters(test_ask_params)):
	var parsed_script = parser.parse_script(params)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())

	assert_true(parsed_array[0][0] == "ASK")

	var result = parsed_array[0][1]

	assert_eq(result["variable"], "answer")

	assert_eq(result["question"], "Hello ?")

var test_ask_default_answer_params = [
	["answer=?\"Hello ?\" \"Bob\""],
	["answer = ? \"Hello ?\" \"Bob\""]
]

func test_ask_default_answer(params=use_parameters(test_ask_default_answer_params)):
	var parsed_script = parser.parse_script(params)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())

	assert_true(parsed_array[0][0] == "ASK")

	var result = parsed_array[0][1]

	assert_eq(result["variable"], "answer")

	assert_eq(result["question"], "Hello ?")

	assert_eq(result["default_answer"], "Bob")

var test_ask_tag_params = [
	["answer=?gd \"Hello ?\""],
	["answer = ? gd \"Hello ?\""]
]

func test_ask_tag(params=use_parameters(test_ask_tag_params)):
	var parsed_script = parser.parse_script(params)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())

	assert_true(parsed_array[0][0] == "ASK")

	var result = parsed_array[0][1]

	assert_eq(result["variable"], "answer")

	assert_eq(result["character_tag"], "gd")

	assert_eq(result["question"], "Hello ?")

var test_ask_all_params = [
	["answer=?gd \"Hello ?\" \"Bob\""],
	["answer = ? gd \"Hello ?\" \"Bob\""]
]

func test_ask_all(params=use_parameters(test_ask_all_params)):
	var parsed_script = parser.parse_script(params)

	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())

	assert_true(parsed_array[0][0] == "ASK")

	var result = parsed_array[0][1]

	assert_eq(result["variable"], "answer")

	assert_eq(result["character_tag"], "gd")

	assert_eq(result["question"], "Hello ?")

	assert_eq(result["default_answer"], "Bob")
