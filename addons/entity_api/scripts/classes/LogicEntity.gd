extends Spatial
class_name LogicEntity, "res://addons/entity_api/icon.png"


var connection_list: Node
var roomNode: Node
var clickable_area: Area
var object_area: Area
var collider: CollisionShape
var object_collider: CollisionShape
var coldata: BoxShape
var csg_preview: CSGBox
var logic_id: int
var inputlist: Array = []


func _init() -> void:
	self.clickable_area = Area.new()
	self.clickable_area.transform.origin.y = 5
	self.add_child(self.clickable_area)
	self.collider = CollisionShape.new()
	self.clickable_area.add_child(self.collider)
	self.coldata = BoxShape.new()
	self.coldata.extents = Vector3(4, 4, 4)
	self.collider.shape = self.coldata
	self.clickable_area.connect("input_event", self, "_on_click")
	
	self.object_area = Area.new()
	self.object_area.transform.origin.y = 5
	self.add_child(self.object_area)
	self.object_collider = CollisionShape.new()
	self.object_area.add_child(object_collider)
	self.object_collider.shape = self.coldata
	self.object_area.connect("body_entered", self, "start_touching_object")
	self.object_area.connect("body_exited", self, "stop_touching_object")
	
	self.csg_preview = CSGBox.new()
	self.csg_preview.transform.origin.y = 5
	self.csg_preview.height = 8
	self.csg_preview.width = 8
	self.csg_preview.depth = 8
	self.csg_preview.material = preload("../../materials/bbox.material")
	self.add_child(self.csg_preview)

func _editor_set_connection_list(list: Node) -> void:
	self.connection_list = list

func _editor_set_room(room: Node) -> void:
	self.roomNode = room

func _on_click(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if !self.collider.disabled and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and self.roomNode.toolSelected == Globals.TOOL.CONNECTION:
		self.connection_list.add_connection(self)
	elif !self.collider.disabled and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and self.roomNode.toolSelected == Globals.TOOL.PLACEENTITY:
		self.queue_free()

func set_collider_disabled(disabled: bool) -> void:
	self.collider.disabled = disabled
	if disabled:
		self.csg_preview.hide()
	else:
		self.csg_preview.show()

func get_collider_disabled() -> bool:
	return self.collider.disabled

func set_click_collider(collider: Shape) -> void:
	self.collider.shape = collider

func set_logic_collider(collider: Shape) -> void:
	self.object_collider.shape = collider

func set_logic_id(id: int) -> void:
	logic_id = id
	LogicManager.add_logic_entity(logic_id, self)

func register_input(input_name: String, function_name: String) -> void:
	LogicManager.add_input(input_name, logic_id, function_name)
	inputlist.append(input_name)

func broadcast(input_name: String, arguments: Dictionary) -> void:
	LogicManager.broadcast(input_name, arguments)

func broadcast_to(id: int, input_name: String, arguments: Dictionary) -> void:
	LogicManager.broadcast_to(input_name, id, arguments)

func get_inputs() -> Array:
	return inputlist

# -v- these should be redefined for your game -v-

func is_player(node: Node) -> bool:
	return node.has_method("_i_am_the_player_fear_me_")

# -^- end -^-

# -v- these can be overridden by your entity as needed -v-

func start_touching_object(node: Node) -> void:
	pass

func stop_touching_object(node: Node) -> void:
	pass

func get_outputs() -> Array:
	return []

# -^- end -^-
