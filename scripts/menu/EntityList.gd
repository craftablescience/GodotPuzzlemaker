extends Tree


var ENTITIES: Dictionary
var root: TreeItem
var children: Dictionary


func _ready() -> void:
	self.root = self.create_item()
	self.set_hide_root(true)
	self.ENTITIES = {}
	self.children = {}
	self._on_search_text_changed("")

func add_category(catName: String, ID: String) -> void:
	self.children[ID] = {"parent": self.create_item(root), "children": {}}
	self.children[ID]["parent"].set_text(0, catName)
	self.children[ID]["parent"].set_metadata(0, "__category__")

func add_item(category: String, itemName: String, itemID: String, entity: PackedScene) -> bool:
	if !(category in self.children.keys()):
		return false;
	self.ENTITIES[category + ":" + itemID] = entity
	self.children[category]["children"][itemID] = {
		"item": self.create_item(self.children[category]["parent"]),
		"name": itemName,
		"node": entity
	}
	self.children[category]["children"][itemID]["item"].set_text(0, itemName)
	self.children[category]["children"][itemID]["item"].set_icon(0, self.ENTITIES[category + ":" + itemID])
	self.children[category]["children"][itemID]["item"].set_icon_max_width(0, 16)
	self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	return true;

func get_selected_entity() -> String:
	if self.get_selected() != null and self.get_selected().get_metadata(0) != "__category__":
		return self.get_selected().get_metadata(0)
	else:
		return ""

func get_entity(entName: String) -> Node:
	return self.ENTITIES[entName]

func get_entity_ID(scene: PackedScene) -> String:
	var c: int = 0
	for i in self.ENTITIES.values():
		if i == scene:
			return self.ENTITIES.keys()[c]
		c += 1
	return ""

func _on_entity_button_pressed() -> void:
	for node in get_parent().get_parent().get_children():
		node.hide()
	get_parent().show()

func _on_Tree_cell_selected() -> void:
	self.release_focus()

func _on_search_text_changed(new_text: String) -> void:
	for category in self.children.keys():
		for itemID in self.children[category]["children"].keys():
			if self.children[category]["children"][itemID]["item"] != null:
				self.children[category]["children"][itemID]["item"].free()
	if new_text == "":
		for category in self.children.keys():
			for itemID in self.children[category]["children"].keys():
				self.children[category]["children"][itemID]["item"] = self.create_item(self.children[category]["parent"])
				self.children[category]["children"][itemID]["item"].set_text(0, self.children[category]["children"][itemID]["name"])
				self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	else:
		for category in self.children.keys():
			for itemID in self.children[category]["children"].keys():
				if new_text.to_lower() in self.children[category]["children"][itemID]["name"].to_lower():
					self.children[category]["children"][itemID]["item"] = self.create_item(self.children[category]["parent"])
					self.children[category]["children"][itemID]["item"].set_text(0, self.children[category]["children"][itemID]["name"])
					self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
