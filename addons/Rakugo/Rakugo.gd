extends Node

# Rakugo
## Setting's strings
const game_version = "addons/rakugo/game_version"
const history_length = "addons/rakugo/history_length"
const narrator_name = "addons/rakugo/narrator/name"
const debug = "addons/rakugo/debug"
const save_folder = "addons/rakugo/save_folder"

#Godot
## Setting's strings
const game_title = "application/config/name"

const version := "2.2"

const StoreManager = preload("res://addons/Rakugo/lib/systems/StoreManager.gd")
const Parser = preload("res://addons/Rakugo/lib/systems/Parser.gd")
const Executer = preload("res://addons/Rakugo/lib/systems/Executer.gd")

var waiting_step := false : get = is_waiting_step

var variable_ask_name: String
var waiting_ask_return := false : get = is_waiting_ask_return

var waiting_menu_return := false : get = is_waiting_menu_return

# when you load game to run last script
var last_thread_datas:Dictionary

@onready var store_manager := StoreManager.new()
@onready var parser := Parser.new()
@onready var executer := Executer.new()
@onready var mutex := Mutex.new()

signal sg_step
signal sg_game_loaded
signal sg_say(character, text)
signal sg_notify(text)
signal sg_ask(character, question, default_answer)
signal sg_menu(choices)
signal sg_custom_regex(key, result)
signal sg_execute_script_start(file_name)
signal sg_execute_script_finished(file_name, error_str)
signal sg_variable_changed(var_name, value)
signal sg_character_variable_changed(character_tag, var_name, value)

## Variables

# Replaces <var_name> in given text with its value
func replace_variables(text:String) -> String:
	var sub_results = executer.regex_cache["VARIABLE_IN_STR"].search_all(text)
	
	for sub_result in sub_results:
		var var_ = Rakugo.get_variable(sub_result.get_string("variable"))
		
		if var_:
			if typeof(var_) != TYPE_STRING:
				var_ = str(var_)

			text = text.replace(sub_result.strings[0], var_)
	
	return text


# Used to be call with call_thread_safe.
func emit_sg_variable_changed(var_name:String, value):
	sg_variable_changed.emit(var_name, value)


# Create or set (if existed) a global or character variable.
# global variable : var_name = "name"
# character variable : var_name = "char_tag.name"
func set_variable(var_name: String, value):
	var vars_ = var_name.split(".")
	
	match vars_.size():
		1:
			mutex.lock()
			store_manager.variables[var_name] = value
			mutex.unlock()

			call_thread_safe("emit_sg_variable_changed", var_name, value)
			return

		2:
			return set_character_variable(vars_[0], vars_[1], value)
		
	push_error("Rakugo does not allow to store variables with more than 1 dot in name.")


# Return a global or character variable if stored.
# global variable : var_name = "name"
# character variable : var_name = "char_tag.name"
func get_variable(var_name: String):
	var vars_ = var_name.split(".")

	match vars_.size():
		1:
			var variable = null

			mutex.lock()
			if store_manager.variables.has(var_name):
				variable = store_manager.variables.get(var_name)
			mutex.unlock()
			
			if variable is String:
				return replace_variables(variable)

			return variable

		2:
			return get_character_variable(vars_[0], vars_[1])

	push_error("Rakugo does not knew a variable called: " + var_name)

	return null


# Return true if a global or character variable is founded with this name.
# global variable : var_name = "name"
# character variable : var_name = "char_tag.name"
func has_variable(var_name: String) -> bool:
	var vars_ = var_name.split(".")

	match vars_.size():
		1:
			var has_variable = false

			mutex.lock()
			has_variable = store_manager.variables.has(var_name)
			mutex.unlock()

			return has_variable

		2:
			return character_has_variable(vars_[0], vars_[1])

	push_error("Rakugo does not knew a variable called: " + var_name)

	return false


## Characters
# create new character, and store it using its tag
func define_character(character_tag: String, character_name: String):
	mutex.lock()
	store_manager.characters[character_tag] = {"name": character_name}
	mutex.unlock()


func has_character(character_tag: String) -> bool:
	var has_character = false

	mutex.lock()
	has_character = store_manager.characters.has(character_tag)
	mutex.unlock()

	return has_character


func get_character(character_tag: String) -> Dictionary:
	var character = {}

	if character_tag.is_empty():
		return character

	mutex.lock()
	character = store_manager.characters.get(character_tag, {})

	if character.is_empty():
		push_error("Rakugo does not knew a character with this tag: " + character_tag)

	mutex.unlock()
	return character


func get_narrator():
	return get_character("narrator")


#Used to be call with call_thread_safe
func emit_sg_character_variable_changed(character_tag: String, var_name: String, value):
	sg_character_variable_changed.emit(character_tag, var_name, value)


func set_character_variable(character_tag: String, var_name: String, value):
	var character = get_character(character_tag)

	mutex.lock()
	if !character.is_empty():
		character[var_name] = value

		call_thread_safe("emit_sg_character_variable_changed", character_tag, var_name, value)
	mutex.unlock()


func character_has_variable(character_tag: String, var_name: String) -> bool:
	var character = get_character(character_tag)

	var has_variable = false

	mutex.lock()
	if !character.is_empty():
		has_variable = character.has(var_name)
	mutex.unlock()
	return has_variable


func get_character_variable(character_tag: String, var_name: String):
	var character = get_character(character_tag)

	var character_variable = null

	mutex.lock()
	if !character.is_empty():
		character_variable = character.get(var_name)

	if character_variable == null:
		push_error(
			(
				"Rakugo character with tag "
				+ character_tag
				+ " does not have this variable: "
				+ var_name
				+ ", returning null"
			)
		)
		push_error("Available variables are: " + str(character.keys()))

	mutex.unlock()

	if character_variable is String:
		return replace_variables(character_variable)

	return character_variable


func _ready():
	var version = ProjectSettings.get_setting(game_version)
	var title = ProjectSettings.get_setting(game_title)
	get_window().set_title(title + " " + version)

	var narrator_name = ProjectSettings.get_setting(narrator_name)
	define_character("narrator", narrator_name)


# Save all variables, characters, script_name and last line readed on last executed script, in user://save/save_name/save.json file.
func save_game(save_name: String = "quick"):
	mutex.lock()
	store_manager.save_game(executer.get_current_thread_datas(), save_name)
	mutex.unlock()


# Load all variables, characters, script_name and last line readed on last executed script, from user://save/save_name/save.json file if existed.
func load_game(save_name := "quick"):
	last_thread_datas = store_manager.load_game(save_name)
	parse_script(last_thread_datas["path"])
	sg_game_loaded.emit()


# Execute the loaded script from last line readed.
func resume_loaded_script() -> int:
	var last_thread_datas_tmp = last_thread_datas

	if last_thread_datas.is_empty():
		push_error("Rakugo does not have script to reload")
		return FAILED
	
	return execute_script(last_thread_datas["file_base_name"], "", last_thread_datas["last_index"])


# Parser
# Parse a script and store it. You can execute it with execute_script.
func parse_script(file_name: String) -> int:
	mutex.lock()
	var rk_lines = store_manager.load_rk(file_name)
	
	if rk_lines.is_empty():
		mutex.unlock()
		return FAILED
	
	var parsed_script = parser.parse_script(rk_lines)
	
	if parsed_script.is_empty():
		mutex.unlock()
		return FAILED
		
	parsed_script["path"] = file_name
	
	store_manager.parsed_scripts[file_name.get_file().get_basename()] = parsed_script
	
	mutex.unlock()
	return OK


# Executer
# Execute a script previously registered with parse_script.
func execute_script(script_name: String, label_name: String = "", index:int = 0) -> int:
	var error = FAILED
	
	mutex.lock()
	var parsed_script = store_manager.parsed_scripts.get(script_name, {})
	
	if parsed_script.is_empty():
		push_error("Rakugo does not have parse a script named: " + script_name)
	else:
		error = executer.execute_script(parsed_script, label_name, index)
	mutex.unlock()
	return error


# Stop the current reading script.
func stop_last_script():
	mutex.lock()
	executer.stop_current_thread()
	mutex.unlock()


# Do parse_script, if return OK then do execute_script.
func parse_and_execute_script(file_name: String, label_name: String = "") -> int:
	var error = FAILED
	
	mutex.lock()
	if parse_script(file_name) == OK:
		error = execute_script(file_name.get_file().get_basename(), label_name)
	mutex.unlock()
	return error


# Call from Executer when a script is started reading.
func send_execute_script_start(file_base_name: String):
	var emit_send_execute_script_start = func():
		sg_execute_script_start.emit(file_base_name)
	
	emit_send_execute_script_start.call_deferred()


# Call from Executer when a script is finished reading.
func send_execute_script_finished(file_base_name: String, error_str:String):
	var emit_sg_execute_script_finished = func():
		sg_execute_script_finished.emit(file_base_name, error_str)
		
	emit_sg_execute_script_finished.call_deferred()


func _exit_tree() -> void:
	mutex.lock()
	executer.stop_current_thread()
	mutex.unlock()


# Todo Handle Error
# Add new custom instruction to RkScript.
func add_custom_regex(key: String, regex: String):
	mutex.lock()
	parser.add_regex_at_runtime(key, regex)
	mutex.unlock()


## Statements
# Used to be call with call_thread_safe.
func emit_sg_step():
	sg_step.emit()


# Call from Executer when is stop the reading process.
func step():
	mutex.lock()
	waiting_step = true
	mutex.unlock()

	call_thread_safe("emit_sg_step")


# Returns true when Rakugo waiting call of do_step.
func is_waiting_step():
	mutex.lock()
	var waiting_step_value = waiting_step
	mutex.unlock()
	return waiting_step_value


# Use it when is_waiting_step return true, to continue script reading process.
func do_step():
	mutex.lock()
	waiting_step = false

	executer.current_semaphore.post()
	mutex.unlock()


# Used to be call with call_thread_safe.
func emit_sg_say(character:Dictionary, text: String):
	sg_say.emit(character, text)


# Call from Executer when is read an instruction say
func say(character_tag: String, text: String):
	var character = get_character(character_tag)

	call_thread_safe("emit_sg_say", character, text)


# Used to be call with call_thread_safe.
func emit_sg_ask(character: Dictionary, question: String, default_answer: String):
	sg_ask.emit(character, question, default_answer)


# Call from Executer when is read an instruction ask.
func ask(variable_name: String, character_tag: String, question: String, default_answer: String):
	mutex.lock()
	waiting_ask_return = true

	variable_ask_name = variable_name
	mutex.unlock()
	
	var character = get_character(character_tag)
	
	call_thread_safe("emit_sg_ask", character, question, default_answer)


# Returns true when Rakugo waiting call of ask_return.
func is_waiting_ask_return():
	var waiting_ask_return_value = false

	mutex.lock()
	waiting_ask_return_value = waiting_ask_return
	mutex.unlock()

	return waiting_ask_return_value


# Use it when is_waiting_ask_return return true, to continue script reading process.
func ask_return(result):
	mutex.lock()
	waiting_ask_return = false
	mutex.unlock()

	set_variable(variable_ask_name, result)

	mutex.lock()
	executer.current_semaphore.post()
	mutex.unlock()


# statement of type menu
# Used to be call with call_thread_safe.
func emit_sg_menu(choices: PackedStringArray):
	sg_menu.emit(choices)


# Call from Executer when is read an instruction menu.
func menu(choices: PackedStringArray):
	mutex.lock()
	waiting_menu_return = true
	mutex.unlock()

	call_thread_safe("emit_sg_menu", choices)


# Returns true when Rakugo waiting call of menu_return.
func is_waiting_menu_return():
	var waiting_menu_return_value = false

	mutex.lock()
	waiting_menu_return_value = waiting_menu_return
	mutex.unlock()

	return waiting_menu_return_value


# Use it when is_waiting_menu_return return true, to continue script reading process.
# index is the index of choosed choice in the choices array given by sg_menu.
func menu_return(index: int):
	mutex.lock()
	waiting_menu_return = false
	
	executer.menu_jump_index = index

	executer.current_semaphore.post()
	mutex.unlock()


# Statement notify
# Used to be call with call_thread_safe.
func emit_sg_notify(text: String):
	sg_notify.emit(text)


# Call from Executer when is read an instruction notify.
func notify(text: String):
	call_thread_safe("emit_sg_notify", text)
