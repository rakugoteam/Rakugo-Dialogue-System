extends Resource
class_name Store

export var game_version:String = ""
export var rakugo_version:String = ""
export var properties:Dictionary = {}
var property_signals:Array = []

func _init():
	properties = {}
	property_signals = []


func _get(property):
	if property in self.get_property_list():
		return self[property]
	elif self.properties.has(property):
		if self.properties[property] != null:
			return self.properties[property]
		else:
			push_warning("Tried to get a variable '%s' erased from the store. Returning false instead." % property)
			return false
	return null


func _set(property, value):
	prints("Store", "_set", property, value)
	if property in self.get_property_list():
		self[property] = value
	else:
		self.properties[property] = value
	if property in property_signals:
		emit_signal("on_%s_changed" % property, property, value)
	return true


func connect_on_property_changed(property:String, target:Object, method:String):
	if not self.has_signal("on_%s_changed" % property):
		property_signals.append(property)
		self.add_user_signal("on_%s_changed" % property, [{'name':'property', 'type':TYPE_STRING}, {'name':'value', 'type':TYPE_NIL}])
	self.connect("on_%s_changed" % property, target, method)


func disconnect_on_property_changed(property:String, target:Object, method:String):
	if self.is_connected("on_%s_changed" % property, target, method):
		self.disconnect("on_%s_changed" % property, target, method)


func replace_connections(new_store):
	new_store.property_signals = self.property_signals.duplicate(true)
	for p in property_signals:
		new_store.add_user_signal("on_%s_changed" % p, [{'name':'property', 'type':TYPE_STRING}, {'name':'value', 'type':TYPE_NIL}])
	
	for s in self.get_signal_list():
		for c in self.get_signal_connection_list(s.name):
			new_store.connect(s, c.target, c.method)
			self.disconnect(s, c.target, c.method)
	pass


func duplicate(_deep:bool=true) -> Resource:
	## Store duplication should always be deep
	var output = .duplicate(_deep)
	output.script = self.script
	for k in self.properties.keys():
		if k != "script" and _can_duplicate(self.properties[k]):
			output.properties[k] = self.properties[k].duplicate(_deep)
	return output


func _can_duplicate(v):
	return v is Object and v.has_method('duplicate')
