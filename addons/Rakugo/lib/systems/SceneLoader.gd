extends Node

var default_force_reload = false
var scene_links:Dictionary = {}
var inverse_scene_links:Dictionary = {}
var preloaded_scenes:Dictionary = {}
var current_scene:String = ''
var current_scene_node:Node

var previous_scene_node:Node

signal scene_changed(scene_node)
#Assess the need of those


func _ready():
	default_force_reload = Settings.get(SettingsList.force_reload)
	var sl_path = Settings.get(SettingsList.scene_links)
	scene_links = load(sl_path).get_as_dict()
	current_scene = Settings.get(SettingsList.main_scene)
	current_scene_node = get_tree().current_scene
	
	for k in scene_links.keys():
		inverse_scene_links[scene_links[k]] = k
	current_scene = inverse_scene_links[current_scene]
	preload_scenes()


func _store(store):
	store.current_scene = current_scene

func _restore(store):
	if store.current_scene != current_scene or default_force_reload:
		load_scene(store.current_scene)


func preload_scenes():
	var i = 0
	for k in scene_links.keys():
		print("Preloading scene '%s'" % k)
		Rakugo.emit_signal("loading", i / scene_links.keys().size())
		self.call_deferred('load_scene_resource', k, scene_links[k])
	Rakugo.emit_signal("loading", 1)
	


func load_scene_resource(key, path, force_reload=false):
	if force_reload or not key in preloaded_scenes:
		preloaded_scenes[key] = ResourceLoader.load(path, "PackedScene", force_reload)


func load_scene(scene:String, force_reload = default_force_reload):
	var scene_entry = get_scene_entry(scene)
	
	if current_scene != scene_entry[0] or force_reload:
		Rakugo.emit_signal("loading", NAN)
		load_scene_resource(scene_entry[0], scene_entry[1], force_reload)
		current_scene = scene_entry[0]
		previous_scene_node = current_scene_node 
		# Prevent previous scene to be freed too soon (in case a Dialogue Thread is not yet finished) 
		current_scene_node = preloaded_scenes[scene_entry[0]].instance()
		Rakugo.clean_scene_anchor()
		Rakugo.scene_anchor.add_child(current_scene_node)
		Rakugo.emit_signal("loading", 1)
		emit_signal("scene_changed", current_scene_node)
		return current_scene_node


func get_scene_entry(scene):
	var scene_path
	var scene_id
	if not scene in self.scene_links:

		if not scene_id in self.inverse_scene_links:
			push_warning("Scene '%s' not found in linker" % scene_id)
			scene_id = scene.get_file()
		else:
			scene_id = self.inverse_scene_links[scene_id]

		scene_path = scene
	else:
		scene_id = scene
		scene_path = self.scene_links[scene]
		
	return [scene_id, scene_path]
