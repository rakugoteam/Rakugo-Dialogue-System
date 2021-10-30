extends Node


var shown = {}
## Shown structure:
#{<radical>:[{<tags>:true}, {<params>}]}


func init():
	Rakugo.SceneLoader.connect("scene_changed", self, "_on_scene_changed")
	self.declare_showables()


func _store(store):
	store.showable_shown = self.shown.duplicate(true)

func _restore(store):
	self.shown = store.showable_shown.duplicate(true)
	apply_shown()


func _on_scene_changed(scene):
	declare_showables()
	clean_shown()
	apply_shown()



func clean_shown():
	var tmp_shown = self.shown.duplicate(true)
	for radical_tag in tmp_shown:
		var tag_used
		for t in tmp_shown[radical_tag][0]:
			tag_used = false
			for n in get_tree().get_nodes_in_group(radical_tag):
				if n.is_in_group(t):
					tag_used = true
					break
			if not tag_used:
				self.shown[radical_tag][0].erase(t)
		if self.shown[radical_tag][0].size() == 0:
			self.shown.erase(radical_tag)


func declare_showables():
	for n in get_tree().get_nodes_in_group("showable"):
		var current_tags = {}
		for g in n.get_groups():
			if g.begins_with("$ "):
				current_tags[g] = true

		var temp_tags = {}
		for t in current_tags.keys():
			if "#" in t:
				t = t.replace('#', n.get_name())
			t = t.to_lower()
			temp_tags[get_radical_tag(t)] = true
			temp_tags[t] = true

		for t in temp_tags.keys():
			n.add_to_group(t)


func get_radical_tag(tag):
	tag = tag.trim_prefix("$ ")
	var tag_components = tag.split(' ', false, 1)
	if tag_components:
		return "$ " + tag_components[0] + " _"
	return ""


func get_matching_tags(tag):
	var to_show = [tag]
	tag = tag.trim_prefix("$ ")

	var tag_components = tag.split(' ', false)
	tag_components.remove(tag_components.size() - 1)

	var composite = ""
	for c in tag_components:
		composite = composite + " " + c
		to_show.append("$" + composite + " *")
	return to_show


func show(tag, args):
	tag = "$ " + tag.trim_prefix("$ ")
	var radical_tag = get_radical_tag(tag)
	var to_show = get_matching_tags(tag)

	var shown_any = false
	for t in to_show:
		if get_tree().get_nodes_in_group(t):
			shown_any = true
			break

	if shown_any:
		self.shown[radical_tag] = [{}, args]
		for t in to_show:
			self.shown[radical_tag][0][t] = true
		apply_shown()


func apply_shown():
	var to_hide = {}
	for n in get_tree().get_nodes_in_group("showable"):
		if n.has_method("hide"):
			to_hide[n] = true
	for n in to_hide:
		n.hide()
	if self.shown:
		for radical_tag in self.shown:
			var first_tag
			for n in get_tree().get_nodes_in_group(radical_tag):
				first_tag = ""
				for t in self.shown[radical_tag][0]:
					if n.is_in_group(t):
						first_tag = t
						break
				if first_tag:
					show_showable(n, first_tag, self.shown[radical_tag][1])
					to_hide.erase(n)


func show_showable(node, tag, args):
	if node.has_method("_show"):
		node._show(tag, args)
	elif node.has_method("show"):
		node.show()
	else:
		push_error(str("Node ", node, " tagged ", tag, " is not showable."))


func hide(tag):
	tag = "$ " + tag.trim_prefix("$ ")
	var radical_tag = get_radical_tag(tag)

	if radical_tag.trim_suffix(" _") == tag.trim_suffix(" _"): # Hide all
		self.shown.erase(radical_tag)
		apply_shown()
	else:
		var to_hide = get_matching_tags(tag)
		
		var hid_any = false
		for t in to_hide:
			if get_tree().get_nodes_in_group(t):
				hid_any = true
				break
		
		if hid_any:
			for t in to_hide:
				if radical_tag in self.shown:
					self.shown[radical_tag][0].erase(t)
					if self.shown[radical_tag][0].size() == 0:
						self.shown.erase(radical_tag)
			apply_shown()
