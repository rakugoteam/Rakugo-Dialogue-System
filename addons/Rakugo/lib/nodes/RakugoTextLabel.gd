tool
extends RichTextLabel
class_name RakugoTextLabel, "res://addons/Rakugo/icons/RakugoTextLabel.svg"

var text_parser : RakugoTextParser setget , _get_text_parser
export(String, MULTILINE) var rakugo_text:String setget _set_rakugo_text, _get_rakugo_text
export(String, "game_setting", "renpy", "bbcode", "markdown") var markup setget _set_markup, _get_markup

var _rakugo_text := ""
var _markup := "project_setting"
var _text_parser : RakugoTextParser

func _ready() -> void:
	bbcode_enabled = true
	_set_rakugo_text(_rakugo_text)

func _get_text_parser() -> RakugoTextParser:
	if !_text_parser:
		if Engine.editor_hint:
			_text_parser = RakugoTextParser.new()
		
		else:
			_text_parser = Rakugo.TextParser as RakugoTextParser
	
	return _text_parser
	
func _set_rakugo_text(value:String) -> void:
	bbcode_enabled = true
	_rakugo_text = value

	var can_be_parsed := false
	can_be_parsed = Engine.editor_hint

	if not can_be_parsed and Rakugo:
		can_be_parsed = Rakugo.started
	
	if can_be_parsed:
		var p = _get_text_parser()
		if p == null:
			return
		
		if value == null:
			return

		bbcode_text = p.parse(value, _markup, Engine.editor_hint)
	
func _get_rakugo_text() -> String:
	return _rakugo_text

func _set_markup(value:="") -> void:	
	_markup = value
	_set_rakugo_text(_rakugo_text)

func _get_markup() -> String:
	return _markup

func resize_to_text(char_size:Vector2, axis:="xy"):
	if "x" in axis:
		rect_size.x += _rakugo_text.length() * char_size.x
	if "y" in axis:
		var new_lines:int = _rakugo_text.split("\n", false).size()
		rect_size.y += new_lines * char_size.y;
