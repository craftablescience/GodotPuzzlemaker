extends Tree


var TEXTURES: Dictionary
var root: TreeItem
var children: Dictionary

signal RemoveTexture(id)


func _ready() -> void:
	self.root = self.create_item()
	self.set_hide_root(true)
	self.TEXTURES = {}
	self.children = {}
	self.add_category("Default", "default")
	# warning-ignore:return_value_discarded
	self.add_item("default", "White", "white", preload("res://images/editor/textures/white.png"), "gpz/default_white")
	self._on_search_text_changed("")

func add_category(catName: String, ID: String) -> void:
	self.children[ID] = {"parent": self.create_item(root), "children": {}}
	self.children[ID]["parent"].set_text(0, catName)
	self.children[ID]["parent"].set_metadata(0, "__category__")

func add_item(category: String, itemName: String, itemID: String, texture: Texture, portal2path = null) -> bool:
	if !(category in self.children.keys()):
		return false;
	if portal2path == null:
		self.TEXTURES[category + ":" + itemID] = {"texture": texture}
	else:
		self.TEXTURES[category + ":" + itemID] = {"texture": texture, "portal2path": portal2path}
	self.children[category]["children"][itemID] = {
		"item": self.create_item(self.children[category]["parent"]),
		"name": itemName,
		"node": texture
	}
	self.children[category]["children"][itemID]["item"].set_text(0, itemName)
	self.children[category]["children"][itemID]["item"].set_icon(0, self.TEXTURES[category + ":" + itemID]["texture"])
	self.children[category]["children"][itemID]["item"].set_icon_max_width(0, Globals.TEXTURE_PREVIEW_WIDTH)
	self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	return true;

func get_selected_texture() -> String:
	if self.get_selected() != null and self.get_selected().get_metadata(0) != "__category__":
		return self.get_selected().get_metadata(0)
	else:
		return ""

func get_texture(texName: String) -> Texture:
	return self.TEXTURES[texName]["texture"]

func _on_texture_button_pressed() -> void:
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
				self.children[category]["children"][itemID]["item"].set_icon(0, self.TEXTURES[category + ":" + itemID]["texture"])
				self.children[category]["children"][itemID]["item"].set_icon_max_width(0, Globals.TEXTURE_PREVIEW_WIDTH)
				self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	else:
		for category in self.children.keys():
			for itemID in self.children[category]["children"].keys():
				if new_text.to_lower() in self.children[category]["children"][itemID]["name"].to_lower():
					self.children[category]["children"][itemID]["item"] = self.create_item(self.children[category]["parent"])
					self.children[category]["children"][itemID]["item"].set_text(0, self.children[category]["children"][itemID]["name"])
					self.children[category]["children"][itemID]["item"].set_icon(0, self.TEXTURES[category + ":" + itemID])
					self.children[category]["children"][itemID]["item"].set_icon_max_width(0, Globals.TEXTURE_PREVIEW_WIDTH)
					self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)

func _on_Remove_pressed() -> void:
	if self.get_selected() != null and self.get_selected().get_metadata(0) != "__category__" and !self.get_selected().get_metadata(0).begins_with("builtin") and !self.get_selected().get_metadata(0).begins_with("default"):
		for category in self.children.keys():
			var namae: String = self.get_selected().get_metadata(0)
			if namae.split(":")[-1] in self.children[category]["children"]:
				self.emit_signal("RemoveTexture", namae)
				self.children[category]["children"][namae.split(":")[-1]]["item"].free()
				self.children[category]["children"].erase(namae.split(":")[-1])
				self._on_search_text_changed(get_parent().get_parent().get_parent().get_node("HBoxContainer/Search").text)
				break
