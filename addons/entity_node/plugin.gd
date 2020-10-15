tool
extends EditorPlugin


func _enter_tree() -> void:
	self.add_custom_type("EntityNode", "Spatial", preload("entity_node.gd"), preload("icon.png"))

func _exit_tree() -> void:
	self.remove_custom_type("EntityNode")
