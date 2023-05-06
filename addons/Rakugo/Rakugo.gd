extends Node

# Rakugo
## Setting's strings
const game_version = "addons/rakugo/game_version"
const force_reload = "addons/rakugo/force_reload"
const auto_mode_delay = "addons/rakugo/auto_mode_delay"
const typing_effect_delay = "addons/rakugo/typing_effect_delay"
const skip_delay = "addons/rakugo/skip_delay"
const rollback_steps = "addons/rakugo/rollback_steps"
const history_length = "addons/rakugo/history_length"
const narrator_name = "addons/rakugo/narrator/name"
const debug = "addons/rakugo/debug"
const save_folder = "addons/rakugo/save_folder"
const test_mode = "addons/rakugo/test_mode"

#Godot
## Setting's strings
const game_title = "application/config/name"
const main_scene = "application/run/main_scene"
const width = "display/window/size/viewport_width"
const height = "display/window/size/viewport_height"
const fullscreen = "display/window/size/fullscreen"
const maximized = "display/window/size/maximized"

const version := "1.1.2"

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
@onready var parser := Parser.new(store_manager)
@onready var executer := Executer.new()

signal sg_step
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
func set_variable(var_name: String, value):
	var vars_ = var_name.split(".")
	
	match vars_.size():
		1:
			store_manager.variables[var_name] = value
			sg_variable_changed.emit(var_name, value)
			return

		2:
			return set_character_variable(vars_[0], vars_[1], value)
		
	push_error("Rakugo does not allow to store variables with more than 1 dot in name.")


func get_variable(var_name: String):
	var vars_ = var_name.split(".")

	match vars_.size():
		1:
			if store_manager.variables.has(var_name):
				return store_manager.variables.get(var_name)

		2:
			return get_character_variable(vars_[0], vars_[1])

	push_error("Rakugo does not knew a variable called: " + var_name)

	return null


func has_variable(var_name: String) -> bool:
	var vars_ = var_name.split(".")

	match vars_.size():
		1:
			return store_manager.variables.has(var_name)

		2:
			return character_has_variable(vars_[0], vars_[1])

	push_error("Rakugo does not knew a variable called: " + var_name)

	return false


## Characters
# create new character, store it into current store using its tag, then return it
func define_character(character_tag: String, character_name: String):
	store_manager.characters[character_tag] = {"name": character_name}


func character_exists(character_tag: String) -> bool:
	push_warning("Obsolete, in next version will be removed, use has_character() instead")
	return has_character(character_tag)

func has_character(character_tag: String) -> bool:
	return store_manager.characters.has(character_tag)


func get_character(character_tag: String) -> Dictionary:
	if character_tag.is_empty():
		push_warning("Character tag is empty")
		return {}

	if has_character(character_tag):
		return store_manager.characters.get(character_tag)

	push_error("Rakugo does not knew a character with this tag: " + character_tag)

	return {}


func get_narrator():
	return get_character("narrator")


func set_character_variable(character_tag: String, var_name: String, value):

	var char_ = get_character(character_tag)

	if !char_.is_empty():
		char_[var_name] = value
		sg_character_variable_changed.emit(character_tag, var_name, value)


func character_has_variable(character_tag: String, var_name: String) -> bool:
	var char_ = get_character(character_tag)

	if !char_.is_empty():
		return char_.has(var_name)

	return false


func get_character_variable(character_tag: String, var_name: String):
	var char_ = get_character(character_tag)

	if !char_.is_empty():
		if char_.has(var_name):
			return char_[var_name]
		else:
			push_error(
				(
					"Rakugo character with tag "
					+ character_tag
					+ " does not have this variable: "
					+ var_name
					+ ", returning null"
				)
			)
			push_error("Available variables are: " + str(char_.keys()))

	return null


func _ready():
	var version = ProjectSettings.get_setting(Rakugo.game_version)
	var title = ProjectSettings.get_setting(Rakugo.game_title)
	get_window().set_title(title + " " + version)

	var narrator_name = ProjectSettings.get_setting(Rakugo.narrator_name)
	define_character("narrator", narrator_name)


func save_game(save_name: String = "quick"):
	store_manager.save_game(executer.get_current_thread_datas(), save_name)


func load_game(save_name := "quick"):
	last_thread_datas = store_manager.load_game(save_name)
	parse_script(last_thread_datas["path"])

func resume_loaded_script():
	if !last_thread_datas.is_empty():
		executer.execute_script(last_thread_datas["file_base_name"], "", last_thread_datas["last_index"])

# Parser
func parse_script(file_name: String) -> int:
	return parser.parse_script(file_name)

# Executer
func execute_script(script_name: String, label_name: String = "") -> int:
	var parsed_script = store_manager.parsed_scripts.get(script_name, {})
	
	if parsed_script.is_empty():
		push_error("Rakugo does not have parse a script named: " + script_name)
		return FAILED
	
	return executer.execute_script(parsed_script, label_name)

func stop_last_script():
	executer.stop_current_thread()

func parse_and_execute_script(file_name: String, label_name: String = "") -> int:
	if parser.parse_script(file_name) == OK:
		return execute_script(file_name.get_file().get_basename(), label_name)
	return FAILED

func send_execute_script_start(file_base_name: String):
	sg_execute_script_start.emit(file_base_name)

func send_execute_script_finished(file_base_name: String, error_str:String):
	sg_execute_script_finished.emit(file_base_name, error_str)


func _exit_tree() -> void:
	executer.stop_current_thread()


# Todo Handle Error
func add_custom_regex(key: String, regex: String):
	parser.add_regex_at_runtime(key, regex)


## Dialogue flow control

# TODO: remove in future
# func exit_dialogue():
# 	self.set_current_dialogue(null)

# func set_current_dialogue(new_dialogue:Dialogue):
# 	if current_dialogue != new_dialogue:
# 		if self.current_dialogue \
# 		and self.current_dialogue.is_running():
# 			self.current_dialogue.exit()

# 		current_dialogue = new_dialogue


## Statements
func step():
	waiting_step = true

	sg_step.emit()


func is_waiting_step():
	return waiting_step


func do_step():
	waiting_step = false

	executer.current_semaphore.post()

# statement of type say
# its make given 'character' say 'text'
# 'parameters' keywords:typing, type_speed, avatar, avatar_state, add
# speed is time to show next letter
func say(character_tag: String, text: String):
	sg_say.emit(get_character(character_tag), text)


# statement of type ask
# with keywords: placeholder
func ask(variable_name: String, character_tag: String, question: String, default_answer: String):
	waiting_ask_return = true

	variable_ask_name = variable_name

	sg_ask.emit(get_character(character_tag), question, default_answer)


func is_waiting_ask_return():
	return waiting_ask_return


func ask_return(result):
	waiting_ask_return = false

	set_variable(variable_ask_name, result)

	executer.current_semaphore.post()


# statement of type menu
func menu(choices: PackedStringArray):
	waiting_menu_return = true

	sg_menu.emit(choices)


func is_waiting_menu_return():
	return waiting_menu_return


func menu_return(index: int):
	waiting_menu_return = false
	
	executer.menu_jump_index = index

	executer.current_semaphore.post()


func notify(text: String):
	sg_notify.emit(text)
