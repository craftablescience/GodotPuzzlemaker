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
	self.add_item("builtin", "White", "white", preload("res://images/editor/textures/white.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Black", "black", preload("res://images/editor/textures/black.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Dev Orange", "dev_orange", preload("res://images/editor/textures/orange_dev.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Dev Grey", "dev_grey", preload("res://images/editor/textures/grey_dev.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Brick 1", "brick_1", preload("res://images/editor/textures/brick_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Building 1", "building_1", preload("res://images/editor/textures/building_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Building 2", "building_2", preload("res://images/editor/textures/building_2.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Carpet 1", "carpet_1", preload("res://images/editor/textures/carpet_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 1", "concrete_1", preload("res://images/editor/textures/concrete_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 2", "concrete_2", preload("res://images/editor/textures/concrete_2.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 3", "concrete_3", preload("res://images/editor/textures/concrete_3.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 4", "concrete_4", preload("res://images/editor/textures/concrete_4.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 5", "concrete_5", preload("res://images/editor/textures/concrete_5.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Concrete 6", "concrete_6", preload("res://images/editor/textures/concrete_6.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Dirt 1", "dirt_1", preload("res://images/editor/textures/dirt_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Grass 1", "grass_1", preload("res://images/editor/textures/grass_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Leather 1", "leather_1", preload("res://images/editor/textures/leather_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Stone 1", "stone_1", preload("res://images/editor/textures/stone_1.png"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Wall 1", "wall_1", preload("res://images/editor/textures/wall_1.png"))
	
	self.add_category("Custom", Globals.CUSTOMID)
	
	PackLoader.set_texture_list(self)


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
