@tool
extends Window

var regex = RegEx.new()
var RkRegex := {
	NAME = "[a-zA-Z][a-zA-Z_0-9]*",
	NUMERIC = "-?[0-9]\\.?[0-9]*",
	STRING = "\".+?\"",
	VARIABLE = "((?<char_tag>{NAME})\\.)?(?<var_name>{NAME})",
	ASSIGNMENT = "(?<assignment>=|\\+=|\\-=|\\*=|\\/=)",
}

@onready
var RkModeUI := [
	%RkModeLabel,
	%RkRegexBox,
	%RkHelp,
]

func _ready():
	%Text.text = "They asked me \"What's going on \\\"in the manor\\\"?\""
	%RkHelp.text = "[b]Rakugo Reg Help[/b]:\n"
	for help in RkRegex:
		%RkHelp.text += "[b]%s[/b]: %s\n" % [
			help, RkRegex[help]]

	update_expression(%Expression.text)
	close_requested.connect(hide)
	%RkModeButton.toggled.connect(_on_rk_mode_toggled)
	%RkCopyBtn.pressed.connect(_on_copy.bind(%Expression))
	%RegexCopyBtn.pressed.connect(_on_copy.bind(%RegExpression))

func _on_copy(line_edit: LineEdit):
	DisplayServer.clipboard_set(line_edit.text)

func _on_rk_mode_toggled(value: bool):
	for ui in RkModeUI:
		ui.visible = value

func update_expression(text):
	regex.compile(text)
	update_text()

func update_text():
	for child in %List.get_children():
		child.queue_free()
	
	if regex.is_valid():
		%RkRegexBox.modulate = Color.WHITE
		%RegexBox.modulate = Color.WHITE
		var matches = regex.search_all(%Text.get_text())
		if matches.size() >= 1:
			# List all matches and their respective captures.
			var match_number = 0
			for regex_match in matches:
				match_number += 1
				# `match` is a reserved GDScript keyword.
				var match_label = Label.new()
				match_label.set("theme_override_constants/outline_size", 2)
				match_label.text = "RegEx match #%d:" % match_number
				match_label.modulate = Color(0.6, 0.9, 1.0)
				%List.add_child(match_label)

				var capture_number = 0
				for result in regex_match.get_strings():
					var capture_label = Label.new()
					capture_label.set("theme_override_constants/outline_size", 2)
					capture_label.text = "Capture group #%d: %s" % [capture_number, result]
					%List.add_child(capture_label)
					capture_number += 1
	else:
		%RkRegexBox.modulate = Color(1, 0.2, 0.1)
		%RegexBox.modulate = Color(1, 0.2, 0.1)
		var label = Label.new()
		label.set("theme_override_constants/outline_size", 2)
		label.text = "Error: Invalid regular expression. Check if the expression is correctly escaped and terminated."
		%List.add_child(label)

func _on_rkreg_expression_text_changed(new_text):
	new_text = new_text.format(RkRegex)
	%RegExpression.text = new_text
	regex.compile(new_text)
	update_text()
