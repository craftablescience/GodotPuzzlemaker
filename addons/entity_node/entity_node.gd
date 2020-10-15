tool
extends Spatial


var clickable_area: Area
var collider: CollisionShape
var coldata: BoxShape


func _ready() -> void:
	self.clickable_area = Area.new()
	self.clickable_area.transform.origin.y = 5
	self.add_child(self.clickable_area)
	self.collider = CollisionShape.new()
	self.clickable_area.add_child(self.collider)
	self.coldata = BoxShape.new()
	self.coldata.extents = Vector3(4, 4, 4)
	self.collider.shape = self.coldata
	self.clickable_area.connect("input_event", self, "_on_click")

func _on_click(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT):
		self.queue_free()

func _enter_tree():
	pass

func _exit_tree() -> void:
	pass
