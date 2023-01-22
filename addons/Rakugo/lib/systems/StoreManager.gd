extends Reference

var save_folder_path:String

#store rakugo variables
var variables: Dictionary

#store rakugo characters
var characters: Dictionary

var parsed_scripts: Dictionary

func _init():
	save_folder_path = ProjectSettings.get_setting("addons/rakugo/save_folder")


## Rk
func load_rk(path: String) -> PoolStringArray:
	var file = File.new()
	
	if file.open(path, File.READ) != OK:
		push_error("can't open file : " + path)
		return PoolStringArray()
	
	var lines = file.get_as_text().split("\n", false)
	
	file.close()

	return lines

## JSON
func load_json(path: String) -> Dictionary:
	var file := File.new()

	if file.open(path, File.READ) != OK:
		push_error("can't open file: " + path)
		return {}

	var data_text: String = file.get_as_text()

	file.close()

	if data_text.empty():
		return {}

	var data_parse: JSONParseResult = JSON.parse(data_text)

	if data_parse.error != OK:
		push_error("error when parse to json this file: " + path)
		return {}

	var final_data = data_parse.result
	if typeof(final_data) == TYPE_DICTIONARY:
		return final_data

	push_error("parsed json is not a dictionary: " + path)
	return {}


func save_json(path: String, data: Dictionary) -> int:
	var file = File.new()

	if file.open(path, File.WRITE) == OK:
		file.store_line(JSON.print(data, "\t", true))

		file.close()

		return OK

	push_error("can't open file: " + path)
	return ERR_FILE_CANT_OPEN

func save_game(thread_datas:Dictionary, save_name: String = "quick") -> int:
	var save_folder = save_folder_path + "/" + save_name

	var directory = Directory.new()

	if !directory.dir_exists(save_folder):
		if directory.make_dir_recursive(save_folder) != OK:
			push_error("can't create dir: " + save_folder)
			return FAILED

	var sava_datas = {"variables": variables, "characters": characters}

	if !thread_datas.empty():
		thread_datas["path"] = parsed_scripts[thread_datas["file_base_name"]]["path"]

		sava_datas["thread_datas"] = thread_datas

	return save_json(save_folder + "/save.json", sava_datas)


func load_game(save_name: String = "quick") -> Dictionary:
	var save_folder = save_folder_path + "/" + save_name

	var directory = Directory.new()

	if directory.dir_exists(save_folder):
		var dico = load_json(save_folder + "/save.json")

		if !dico.empty():
			variables = dico["variables"]
			characters = dico["characters"]

			return dico.get("thread_datas", {})

	push_error("save folder does not exist at path: " + save_folder)
	return {}
