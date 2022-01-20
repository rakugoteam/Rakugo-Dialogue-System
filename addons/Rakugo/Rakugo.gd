extends Node

const rakugo_version := "3.3"

var current_scene_name := ""
var current_scene_path := ""
var current_scene_node: Node = null
var current_dialogue:Dialogue = null setget set_current_dialogue

var store = null setget , get_current_store
var persistent = null setget , get_persistent_store

# don't save this
var scene_anchor:Node

var active := false
var loading_in_progress := false
var started := false
var auto_stepping := false
var skipping := false

var is_waiting_step:=false
var is_waiting_ask_return:=false
var is_waiting_menu_return:=false

# timers use by rakugo
onready var auto_timer := $AutoTimer
onready var skip_timer := $SkipTimer

onready var StoreManager: = $StoreManager
onready var History: = $History
onready var StepBlocker = $StepBlocker
onready var Say = $Statements/Say
onready var Ask = $Statements/Ask
onready var Menu = $Statements/Menu

signal step()
signal say(character, text, parameters)
signal notify(text, parameters)
signal ask(default_answer, parameters)
signal ask_return(result)
signal menu(choices, parameters)
signal menu_return(result)
signal started()
signal game_ended()
signal loading(progress) ## Progress is to be either NaN or [0,1], loading(1) meaning loading finished.

func _ready():
	self.scene_anchor = get_tree().get_root()
	StoreManager.init()
	History.init()
	var version = Settings.get(SettingsList.game_version)
	var title = Settings.get(SettingsList.game_title)
	OS.set_window_title(title + " " + version)

## Rakugo flow control

# it starts Rakugo
func start(after_load:bool = false):
	started = true
	if not after_load:
		emit_signal("started")
	jump("", "", "")# Engage the auto-start

func save_game(save_name:String = "quick"):
	StoreManager.save_persistent_store()
	debug(["save data to :", save_name])
	return StoreManager.save_store_stack(save_name)

func load_game(save_name := "quick"):
	return StoreManager.load_store_stack(save_name)

func rollback(amount:int = 1):
	var next = self.StoreManager.current_store_id + amount
	self.StoreManager.change_current_stack_index(next)

func prepare_quitting():
	if self.started:
		self.save_game("auto")
	
	Settings.save_property_list()
	
	if current_dialogue:
		current_dialogue.exit()

func reset_game():
	started = false
	emit_signal("game_ended")

## Dialogue flow control

func do_step(_unblock=false):
	is_waiting_step = false
	if _unblock or not StepBlocker.is_blocking():
		StoreManager.stack_next_store()
		# print("Emitting _step")
		get_tree().root.propagate_call('_step')
		StoreManager.next_store_id()
	else:
		# print("Emitting _blocked_step")
		get_tree().root.propagate_call('_blocked_step')

func exit_dialogue():
	self.set_current_dialogue(null)

func set_current_dialogue(new_dialogue:Dialogue):
	if current_dialogue != new_dialogue:
		if self.current_dialogue \
		and self.current_dialogue.is_running():
			self.current_dialogue.exit()

		current_dialogue = new_dialogue

func activate_skipping():
	self.skipping = true
	skip_timer.start()

func deactivate_skipping():
	self.skipping = false

func activate_auto_stepping():
	self.auto_stepping = true
	auto_timer.start()

func deactivate_auto_stepping():
	self.auto_stepping = false

## Utils
func clean_scene_anchor():
	if self.scene_anchor != get_tree().get_root():
		for c in self.scene_anchor.get_children():
			self.scene_anchor.remove_child(c)

# create new character, store it into current store using its tag, then return it
func define_character(character_name:String, character_tag:String, color=null) -> Character:
	var new_character = Character.new()
	if color:
		new_character.init(character_name, character_tag, color)

	else:
		new_character.init(character_name, character_tag)
		
	StoreManager.get_current_store()[character_tag] = new_character
	return new_character

func debug_dict(parameters:Dictionary, parameters_names:Array = [], some_custom_text:String = "") -> String:
	var dbg = ""

	for k in parameters_names:
		if k in parameters:
			if not k in [null, ""]:
				dbg += k + ":" + str(parameters[k]) + ", "

	if parameters_names.size() > 0:
		dbg.erase(dbg.length() - 2, 2)

	return some_custom_text + dbg

# for printing debugs is only print if debug_on == true
# put some string array or string as argument
func debug(some_text = []):
	if not Settings.get(SettingsList.debug):
		return

	if not started:
		return

	if typeof(some_text) == TYPE_ARRAY:
		var new_text = ""

		for i in some_text:
			new_text += str(i) + " "

		some_text = new_text

	print(some_text)

## Statements

func step():
	is_waiting_step = true
	emit_signal("step")

# statement of type say
# its make given 'character' say 'text'
# 'parameters' keywords:typing, type_speed, avatar, avatar_state, add
# speed is time to show next letter
func say(character, text:String, parameters:Dictionary):
	Say.exec(character, text, parameters)

# statement of type ask
# with keywords: placeholder
func ask(default_answer:String, parameters:Dictionary):
	is_waiting_ask_return = true
	Ask.exec(default_answer, parameters)
	
func ask_return(result:String):
	is_waiting_ask_return = false
	Ask.return(result)

# statement of type menu
func menu(choices:Array, parameters:Dictionary):
	is_waiting_menu_return = true
	Menu.exec(choices, parameters)
	
func menu_return(result:int):
	is_waiting_menu_return = false
	Menu.return(result)

func notify(text:String, parameters:Dictionary):
	emit_signal('notify', text, parameters)

# use this to change/assign current scene and dialogue
# id_of_current_scene is id to scene defined in scene_links or full path to scene
func jump(scene_id:String, dialogue_name:String, event_name:="", force_reload = null):
	if force_reload != null:
		if force_reload:# Sanitize potentially non bool into bool
			$Statements/Jump.invoke(scene_id, dialogue_name, event_name, true)

		else:
			$Statements/Jump.invoke(scene_id, dialogue_name, event_name, false)

	else:
		$Statements/Jump.invoke(scene_id, dialogue_name, event_name)

## Wrapper getters setters

func get_current_store():
	return StoreManager.get_current_store()

func get_persistent_store():
	return StoreManager.get_persistent_store()

