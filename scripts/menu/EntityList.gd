extends Tree


var root: TreeItem
var children: Dictionary


func _ready() -> void:
	self.root = self.create_item()
	self.set_hide_root(true)
	self.children = {
		"builtin": {
			"parent": self.create_item(root),
			"children": {}
		}
	}
	self.children["builtin"]["parent"].set_text(0, "Built-In")
	
	self.add_item("builtin", "Test Entity", "testEntity", Spatial.new())

func add_category(catName: String, ID: String) -> void:
	self.children[ID] = {"parent": self.create_item(root), "children": {}}
	self.children[ID]["parent"].set_text(0, catName)

func add_item(category: String, itemName: String, itemID: String, entity: Node) -> bool:
	if !(category in self.children.keys()):
		return false;
	self.children[category]["children"][itemID] = {
		"item": self.create_item(self.children[category]["parent"]),
		"node": entity
	}
	self.children[category]["children"][itemID]["item"].set_text(0, itemName)
	return true;


func _on_texture_button_pressed() -> void:
	for node in get_parent().get_parent().get_children():
		node.hide()
	get_parent().show()


func _on_reload() -> void:
	if self.visible:
		print("EntityList._on_reload") # TODO
