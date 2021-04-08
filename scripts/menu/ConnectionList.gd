extends VBoxContainer


onready var connectionitem_scene: PackedScene = preload("res://scenes/menu/ConnectionItem.tscn")
var isListeningForInput: Panel = null


func _on_connection_button_pressed() -> void:
	for node in get_parent().get_parent().get_children():
		node.hide()
	get_parent().show()

func _on_rebuild_connectionlist(removed_ent_logic_ids: Array) -> void:
	for id in removed_ent_logic_ids:
		for node in get_children():
			if node.input_logic_id == id or node.output_logic_id == id:
				remove_child(node)
				node.queue_free()

func set_input_listener(node: Node) -> void:
	if isListeningForInput != null:
		isListeningForInput.self_modulate = Color.white
	isListeningForInput = node
	isListeningForInput.self_modulate = Color.blue

func add_connection(entity: Node) -> void:
	if isListeningForInput != null:
		if isListeningForInput.output_logic_id == entity.logic_id:
			return
		isListeningForInput.set_inputs(entity.get_inputs())
		isListeningForInput.set_input_id(entity.logic_id)
		isListeningForInput = null
		return
	var new_connection: Panel = connectionitem_scene.instance()
	new_connection.set_outputs(entity.get_outputs())
	new_connection.set_output_id(entity.logic_id)
	self.add_child(new_connection)

func remove_connection(connection: Panel) -> void:
	# todo
	remove_child(connection)
	connection.queue_free()
