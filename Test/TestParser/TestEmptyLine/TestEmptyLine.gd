extends GutTest

const Parser = preload("res://addons/Rakugo/lib/systems/Parser.gd")

@onready var parser := Parser.new()

var rk_script = [
	"",
	"	",
	"			"
]

func test_empty_line():
	var parsed_script = parser.parse_script(rk_script)
	
	assert_false(parsed_script.is_empty())
	
	assert_true(parsed_script.get("parse_array", [""]).is_empty())
	assert_true(parsed_script.get("labels", [""]).is_empty())
	
