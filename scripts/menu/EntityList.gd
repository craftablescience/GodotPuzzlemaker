extends Tree


var ENTITIES: Dictionary
var root: TreeItem
var children: Dictionary


func _ready() -> void:
	self.root = self.create_item()
	self.set_hide_root(true)
	self.ENTITIES = {}
	self.children = {
		"builtin": {
			"parent": self.create_item(root),
			"children": {}
		}
	}
	self.children["builtin"]["parent"].set_text(0, "Built-In")
	
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Player Spawn", Globals.PLAYER_START, preload("res://scenes/entities/PlayerStart.scn"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Coin", "coin", preload("res://scenes/entities/CoinEntity.scn"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Table", "table", preload("res://scenes/entities/TableEntity.scn"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Enemy", "enemy", preload("res://scenes/entities/EnemyEntity.scn"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Direction Helper", "direction_gizmo", preload("res://scenes/entities/DirectionGizmo.scn"))
	# warning-ignore:return_value_discarded
	self.add_item("builtin", "Light", "omnilight", preload("res://scenes/entities/LightEntity.scn"))
	
	self.add_category("Custom", Globals.CUSTOMID)

	add_to_group("ENTITYLIST", true)


func add_category(catName: String, ID: String) -> void:
	self.children[ID] = {"parent": self.create_item(root), "children": {}}
	self.children[ID]["parent"].set_text(0, catName)

func add_item(category: String, itemName: String, itemID: String, entity: PackedScene) -> bool:
	if !(category in self.children.keys()):
		return false;
	self.ENTITIES[category + ":" + itemID] = entity
	self.children[category]["children"][itemID] = {
		"item": self.create_item(self.children[category]["parent"]),
		"node": entity
	}
	self.children[category]["children"][itemID]["item"].set_text(0, itemName)
	self.children[category]["children"][itemID]["item"].set_icon(0, self.ENTITIES[category + ":" + itemID])
	self.children[category]["children"][itemID]["item"].set_icon_max_width(0, 16)
	self.children[category]["children"][itemID]["item"].set_metadata(0, category + ":" + itemID)
	return true;

func get_selected_entity() -> String:
	if self.get_selected() != null:
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

func _on_search() -> void:
	if get_parent().visible:
		print("EntityList._on_search") # TODO
