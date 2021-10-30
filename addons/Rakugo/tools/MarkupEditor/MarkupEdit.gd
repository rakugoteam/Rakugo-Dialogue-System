extends VBoxContainer

export(Array, String, FILE, "*.json") var jsons

export var markups_options_nodepath : NodePath
export var layout_options_nodepath : NodePath
export var layout_nodepath : NodePath
export var code_edit_nodepath : NodePath
export var rakugo_text_label_nodepath : NodePath

onready var markups_options : OptionButton = get_node(markups_options_nodepath)
onready var layout_options : OptionButton = get_node(layout_options_nodepath)
onready var layout : GridContainer = get_node(layout_nodepath)
onready var code_edit : CodeEdit = get_node(code_edit_nodepath)
onready var rakugo_text_label : RakugoTextLabel = get_node(rakugo_text_label_nodepath)

var markup_id := 0

func _ready():
	markups_options.connect("item_selected", self, "_on_option_selected")
	layout_options.connect("item_selected", self, "switch_layout")
	code_edit.connect("text_changed", self, "_on_text_changed")

func switch_layout(id := 0):
	layout.columns = id + 1

func _on_option_selected(id: int):
	if id != markup_id:
		code_edit.switch_config(jsons[id])
		var markup = markups_options.get_item_text(id)
		rakugo_text_label.markup = markup.to_lower()
		markup_id = id

	rakugo_text_label.rakugo_text = code_edit.text

func _on_text_changed():
	var id = markups_options.get_selected_id()
	_on_option_selected(id)
