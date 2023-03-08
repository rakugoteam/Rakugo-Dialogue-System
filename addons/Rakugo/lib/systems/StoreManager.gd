extends RefCounted

var save_folder_path:String

#store rakugo variables
var variables: Dictionary

#store rakugo characters
var characters: Dictionary

var parsed_scripts: Dictionary

func _init():
	save_folder_path = ProjectSettings.get_setting("addons/rakugo/save_folder")


## Rk
func load_rk(path: String) -> PackedStringArray:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("can't open file : " + path)
		return PackedStringArray()
	
	var lines = PackedStringArray()
	
	while file.get_position() < file.get_length():
		lines.push_back(file.get_line())
	
	file.close()

	return lines

## JSON
func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("can't open file: " + path)
		return {}

	var data_text: String = file.get_as_text()

	file.close()

	if data_text.is_empty():
		push_error("file to parse is empty: " + path)
		return {}

	var json := JSON.new()
	
	if json.parse(data_text) != OK:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", path, " at line ", json.get_error_line())
	
	var data_parsed = json.get_data()
	
	if typeof(data_parsed) != TYPE_DICTIONARY:
		push_error("parsed json is not a dictionary: " + path)
		return {}
		
	return data_parsed

func save_json(path: String, data: Dictionary) -> int:
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("can't open file: " + path)
		return ERR_FILE_CANT_OPEN

	file.store_line(JSON.stringify(data, "\t", true))

	file.close()
	
	return OK
	

func save_game(thread_datas:Dictionary, save_name: String = "quick") -> int:
	var save_folder = save_folder_path + "/" + save_name

	if !DirAccess.dir_exists_absolute(save_folder):
		if DirAccess.make_dir_recursive_absolute(save_folder) != OK:
			push_error("can't create dir: " + save_folder)
			return FAILED

	var sava_datas = {"variables": variables, "characters": characters}

	if !thread_datas.is_empty():
		thread_datas["path"] = parsed_scripts[thread_datas["file_base_name"]]["path"]

		sava_datas["thread_datas"] = thread_datas

	return save_json(save_folder + "/save.json", sava_datas)


func load_game(save_name: String = "quick") -> Dictionary:
	var save_folder = save_folder_path + "/" + save_name

	if !DirAccess.dir_exists_absolute(save_folder):
		push_error("save folder does not exist at path: " + save_folder)
		return {}

	var dico = load_json(save_folder + "/save.json")

	if dico.is_empty():
		return {}

	variables = dico["variables"]
	characters = dico["characters"]

	return dico.get("thread_datas", {})
