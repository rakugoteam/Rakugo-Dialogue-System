tool
extends TextEdit
class_name CodeEdit, "res://addons/Rakugo/icons/CodeEdit.svg"

export(Array, String, FILE, "*.json") var jsons

func _ready() -> void:
	syntax_highlighting = true
	_add_keywords_highlighting()

func switch_config(json_file:String, id:=0) -> void:
	clear_colors()
	jsons[id] = json_file
	_add_keywords_highlighting()

func _add_keywords_highlighting() -> void:
	if jsons.size() > 0:
		for json in jsons:
			load_json_config(json)


func add_json_keywords_colors(json: String, color: Color) -> void:
	var content : = get_file_content(json)
	var keywords : Array = parse_json(content)
	
	for keyword in keywords:
		add_keyword_color(keyword, color)

func load_json_config(json: String) -> void:
	var content : = get_file_content(json)
	var config : Dictionary = parse_json(content)

	var load_classes := false
	var class_color := Color(0, 0, 0)
	var member_color := Color(0, 0, 0)

	for conf in config:
		var c = config[conf]
		var color : Color = Color(c["color"])
		prints(conf, color)

		match conf:
			"class":
				load_classes = true
				class_color = color

			"member":
				member_color = color
			
		if c.has("sings"):
			var s = c["sings"]
			add_color_region(s[0], s[1], color)
		
		if c.has("keywords"):
			for k in c["keywords"]:
				add_keyword_color(k, color)

	if load_classes:
		load_gds_classes(class_color, member_color)
			

func load_gds_classes(class_color:Color, member_color:Color) -> void:
	var classes : = ClassDB.get_class_list()
	
	for cls in classes:
		add_keyword_color(cls, class_color)
		var properties : = ClassDB.class_get_property_list(cls)
		
		for property in properties:
			for key in property:
				add_keyword_color(key, member_color)

func get_file_content(path:String) -> String:
	var file = File.new()
	var error : int = file.open(path, file.READ)
	var content : = ""
	
	if error == OK:
		content = file.get_as_text()
		file.close()

	return content
