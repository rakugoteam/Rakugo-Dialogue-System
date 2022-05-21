extends Node

const save_folder_path = "user://saves"

var store_stack = []
var store_stack_max_length = 5
var current_store_id = 0
var persistent_store = null


signal saved

#store rakugo variables
var variables:Dictionary

#store rakugo characters
var characters:Dictionary

## JSON
func load_json(path: String) -> Dictionary:
	# An easy function to load json files and handle common errors.
	var file := File.new()
	if file.open(path, File.READ) != OK:
		file.close()
		return {}
	var data_text: String = file.get_as_text()
	file.close()
	if data_text.empty():
		return {}
	var data_parse: JSONParseResult = JSON.parse(data_text)
	if data_parse.error != OK:
		return {}

	var final_data = data_parse.result
	if typeof(final_data) == TYPE_DICTIONARY:
		return final_data
	
	# If everything else fails
	return {}

func save_json(path: String, data: Dictionary) -> int:
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err == OK:
		file.store_line(JSON.print(data, "\t", true))
	file.close()
	return err

## Variables
func load_variables(save_name:String = "quick"):
	variables = load_json(save_folder_path + "/" + save_name + "/variables.json")
	
func save_variables(save_name:String = "quick"):
	save_json(save_folder_path + "/" + save_name + "/variables.json", variables)

## Characters
func load_characters(save_name:String = "quick"):
	characters = load_json(save_folder_path + "/" + save_name + "/characters.json")
	
func save_characters(save_name:String = "quick"):
	save_json(save_folder_path + "/" + save_name + "/characters.json", characters)

func save_game(save_name:String = "quick"):
	var save_folder = save_folder_path + "/" + save_name
	
	var directory = Directory.new()
	
	if !directory.dir_exists(save_folder):
		directory.make_dir_recursive(save_folder)
	
	save_variables(save_name)
	
	save_characters(save_name)
	
func load_game(save_name:String = "quick"):
	var save_folder = save_folder_path + "/" + save_name
	
	var directory = Directory.new()
	
	if directory.dir_exists(save_folder):
		load_variables(save_name)
	
		load_characters(save_name)

func get_save_path(save_name, no_ext=false):
	save_name = save_name.replace('.tres', '')
	save_name = save_name.replace('.res', '')
	var savefile_path = save_folder_path.plus_file(save_name)

	if not no_ext:
		if ProjectSettings.get_setting('rakugo/saves/test_mode'):
			savefile_path += ".tres"

		else:
			savefile_path += ".res"

	return savefile_path

func get_save_name(save_name):
	save_name = save_name.split('/', false)
	save_name = save_name[save_name.size()-1]
	save_name = save_name.replace('.tres', '')
	save_name = save_name.replace('.res', '')
	return save_name

### Store lifecycle

func call_for_restoring():
	# this try call is for _restore() on all nodes in scene
	get_tree().root.propagate_call('_restore', [get_current_store()])

func call_for_storing():
	# this try call is for _store() on all nodes in scene
	get_tree().root.propagate_call('_store', [get_current_store()])

func get_current_store():
	return store_stack[current_store_id]

func stack_next_store():
	self.call_for_storing()
	
	prints("store_stack", store_stack)
	var previous_store = store_stack[0].duplicate()
	previous_store.replace_connections(store_stack[0])
	store_stack.append(previous_store)
	store_stack.invert()
	prints("store_stack after changes", store_stack)
	
	self.prune_back_stack()

func change_current_stack_index(index):
	if current_store_id == 0:
		self.call_for_storing()

	index = clamp(index, 0, store_stack.size()-1)
	if index == current_store_id:
		return

	store_stack[current_store_id].replace_connections(store_stack[index])
	current_store_id = index
	
	self.call_for_restoring()

### Store Stack

func init_store_stack():
	store_stack_max_length = ProjectSettings.get_setting(Rakugo.rollback_steps)
	var new_save := Store.new()
	new_save.game_version = ProjectSettings.get_setting(Rakugo.game_version)
	new_save.rakugo_version = Rakugo.rakugo_version
	new_save.scene = Rakugo.current_scene_name
	new_save.history = []
	store_stack = [new_save]

func next_store_id():
	# this way fixed bug that store stack could't rollforward
	current_store_id = store_stack.size()-1

func prune_back_stack():
	store_stack = store_stack.slice(0, store_stack_max_length - 1)

func save_store_stack(save_name: String) -> bool:
	call_for_storing()
	
	var packed_stack = StoreStack.new()
	packed_stack.stack = self.store_stack
	packed_stack.current_id = self.current_store_id

	var savefile_path = self.get_save_path(save_name)

	var error := ResourceSaver.save(savefile_path, packed_stack)

	if error != OK:
		print("There was issue writing save %s to %s error_number: %s" % [save_name, savefile_path, error])
		return false

	return  true

func load_store_stack(save_name: String):
	Rakugo.loading_in_progress = true
	Rakugo.debug(["load data from:", save_name])

	var file := File.new()

	var savefile_path = self.get_save_path(save_name)

	if not file.file_exists(savefile_path):
		push_error("Save file %s doesn't exist" % savefile_path)
		Rakugo.loading_in_progress = false
		return false

	unpack_data(savefile_path)

	#Rakugo.start(true)
	#Rakugo.load_scene(get_current_store().scene)

	call_for_restoring()
	
	yield(Rakugo, "started")

	Rakugo.loading_in_progress = false
	return true

func unpack_data(path:String) -> Store:
	var packed_stack:StoreStack = load(path) as StoreStack

	packed_stack = packed_stack.duplicate()
	
	self.store_stack = []

	for s in packed_stack.stack:
		self.store_stack.append(s.duplicate())

	self.current_store_id = packed_stack.current_id

	var save = get_current_store()
	var game_version = save.game_version
	
	return save


### Persistent store

func get_persistent_store():
	return persistent_store

func init_persistent_store():
	var file = File.new()
	var persistent_path = save_folder_path + "persistent.tres"
	if file.file_exists(persistent_path):
		persistent_store = load(persistent_path)
	else:
		persistent_store = Store.new()
	persistent_store.game_version = ProjectSettings.get_setting(Rakugo.game_version)
	persistent_store.rakugo_version = Rakugo.rakugo_version

func save_persistent_store():
	var error = ResourceSaver.save(save_folder_path + "persistent.tres", persistent_store)
	if error != OK:
		print("Error writing persistent store %s to %s error_number: %s" % ["persistent.tres", save_folder_path, error])
	
	emit_signal("saved")


func _get(property):
	return persistent_store._get(property)

func _set(property, value):
	return persistent_store._set(property, value)
