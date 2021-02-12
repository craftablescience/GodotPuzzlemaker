extends Node


var vmf_class_name: String = "UntitledClass"
var properties: Dictionary
var auto_properties: Array
var children: Array


func _init(className: String) -> void:
	self.properties = {}
	self.auto_properties = []
	self.children = []
	self.setVmfClassName(className)

func getAsStr(tab_level: int = -1) -> String:
	var string: String = ""
	var tab_prefix: String = ""
	for i in range(tab_level):
		tab_prefix += "\t"
	var tab_prefix_inner = tab_prefix + "\t"
	if self.vmf_class_name != "":
		string += tab_prefix + self.vmf_class_name + "\n"
		string += tab_prefix + "{\n"
	for attr_name in self.auto_properties:
		var value = self.get(attr_name)
		if !(value == null):
			string += tab_prefix_inner + "\"" + str(attr_name) + "\" \"" + str(value) + "\"\n"
	for key in self.properties.keys():
		string += tab_prefix_inner + "\"" + str(key) + "\" " + "\"" + str(self.properties[key]) + "\"\n"
	for child in self.children:
		string += child.getAsStr(tab_level + 1)
	if self.vmf_class_name != "":
		string += tab_prefix + "}\n"
	return string

func setVmfClassName(className: String) -> void:
	self.vmf_class_name = className

func getVmfClassName() -> String:
	return self.vmf_class_name

func getProperties() -> Dictionary:
	return self.properties

func getAutoProperties() -> Array:
	return self.auto_properties

func getChildren() -> Array:
	return self.children
