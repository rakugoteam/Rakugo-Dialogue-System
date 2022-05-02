extends Node

const default_window_size := Vector2(1024, 600)
var default_property_list := {}
var property_list := {}
var audio_buses := {}

signal window_size_changed(prev, now)
signal window_fullscreen_changed(value)

# TODO
func load_property_list():
#	if Rakugo.persistent.get('settings'):
#		property_list = Rakugo.persistent.get('settings')
#	else:
#		save_property_list()
	pass

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	load_property_list()

func save_conf() -> void:
	var config = ConfigFile.new()

	var audio_bus = [
		"Master",
		"BGM",
		"SFX",
		"Dialogs"
	]

	for bus_name in audio_bus:
		var bus_id = AudioServer.get_bus_index(bus_name)
		var mute = AudioServer.is_bus_mute(bus_id)
		var volume = AudioServer.get_bus_volume_db(bus_id)
		config.set_value("audio", bus_name + "_mute", mute)
		config.set_value("audio", bus_name + "_volume", volume)
		audio_buses[bus_name] = {"mute":mute, "volume": volume}

# TODO
func save_property_list():
#	Rakugo.persistent.settings = property_list
#	Rakugo.StoreManager.save_persistent_store()
 pass

# TODO
func set(property, value, save_changes=true):
#	property_list[property] = value
#	if save_changes:
#		Rakugo.StoreManager.save_persistent_store()
	pass


