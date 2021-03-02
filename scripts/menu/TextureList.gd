extends Tree


var TEXTURES: Dictionary
var root: TreeItem
var children: Dictionary


func _ready() -> void:
	self.root = self.create_item()
	self.set_hide_root(true)
	self.TEXTURES = {}
	self.children = {
		"builtin": {
			"parent": self.create_item(root),
			"children": {}
		}
	}
	self.children["builtin"]["parent"].set_text(0, "Built-In")
	
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "White", "white", preload("res://images/editor/white.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Black", "black", preload("res://images/editor/black.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Dev Orange", "dev_orange", preload("res://images/editor/orange_dev.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Dev Grey", "dev_grey", preload("res://images/editor/grey_dev.png"))
	
	self.add_category("Custom", Globals.CUSTOMID)

	add_to_group("TEXTURELIST", true)


func add_category(catName: String, ID: String) -> void:
	self.children[ID] = {"parent": self.create_item(root), "children": {}}
	self.children[ID]["parent"].set_text(0, catName)

func add_item(category: String, itemName: String, itemID: String, texture: Texture) -> bool:
	if !(category in self.children.keys()):
		return false;
	self.TEXTURES[category + ":" + itemID] = texture
	self.children[category]["children"][itemID] = {
		"item": self.create_item(self.children[category]["parent"]),
		"node": texture
	}
	self.children[category]["children"][itemID]["item"].set_text(0, itemName)
	self.children[category]["children"][itemID]["item"].set_icon(0, self.TEXTURES[category + ":" + itemID])
	self.children[category]["children"][itemID]["item"].set_icon_max_width(0, 16)
	self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	return true;

func get_selected_texture() -> String:
	if self.get_selected() != null:
		return self.get_selected().get_metadata(0)
	else:
		return ""

func get_texture(texName: String) -> Texture:
	return self.TEXTURES[texName]


func _on_texture_button_pressed() -> void:
	for node in get_parent().get_parent().get_children():
		node.hide()
	get_parent().show()

func _on_search() -> void:
	if get_parent().visible:
		print("TextureList._on_search") # TODO

func _on_Tree_cell_selected() -> void:
	self.release_focus()
