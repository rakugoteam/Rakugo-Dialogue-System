extends Node

func invoke(scene_id: String, dialogue_name: String, event_name: String, force_reload = null) -> void:
	if scene_id:
		if force_reload != null:
			Rakugo.load_scene(scene_id, force_reload)
		else:
			Rakugo.load_scene(scene_id)
	
	var dialogue_node

	var current_scene_node = get_tree().current_scene
	if dialogue_name:
		#print("Looking for Dialogue '%s' to start"%dialogue_name)
		dialogue_node = get_dialogue(current_scene_node, dialogue_name)
	else:
		dialogue_node = get_first_autostart_dialogue(current_scene_node)
	if dialogue_node:
		#print("Dialogue found, starting ...")
		if event_name:
			dialogue_node.start(event_name)
		else:
			dialogue_node.start()
	elif dialogue_name:
		push_warning("No Dialogue named '%s' found." % dialogue_name)

func get_dialogue(node, dialogue_name):
	if node.name == dialogue_name and node is Dialogue:
		return node

	for c in node.get_children():
		var out = get_dialogue(c, dialogue_name)
		if out:
			return out

	return null

func get_first_autostart_dialogue(node):
	if node is Dialogue and node.auto_start:
		return node

	for c in node.get_children():
		var out = get_first_autostart_dialogue(c)
		
		if out:
			return out

	return null
