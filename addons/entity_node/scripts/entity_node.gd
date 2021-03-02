tool
extends Spatial


var clickable_area: Area
var collider: CollisionShape
var coldata: BoxShape
var csg_preview: CSGBox


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
	self.csg_preview = CSGBox.new()
	self.csg_preview.transform.origin.y = 5
	self.csg_preview.height = 8
	self.csg_preview.width = 8
	self.csg_preview.depth = 8
	self.csg_preview.material = preload("../materials/bbox.material")
	self.add_child(self.csg_preview)

func _on_click(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if !self.collider.disabled and (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT):
		self.queue_free()

func set_collider_disabled(disabled: bool) -> void:
	self.collider.disabled = disabled
	if disabled:
		self.csg_preview.hide()
	else:
		self.csg_preview.show()

func get_collider_disabled() -> bool:
	return self.collider.disabled

func _enter_tree():
	pass

func _exit_tree() -> void:
	pass
