extends Spatial


var XP: Sprite3D
var XM: Sprite3D
var YP: Sprite3D
var YM: Sprite3D
var ZP: Sprite3D
var ZM: Sprite3D

var XPH: Spatial
var XMH: Spatial
var YPH: Spatial
var YMH: Spatial
var ZPH: Spatial
var ZMH: Spatial

var planes: Dictionary


func _ready():
	
	self.XP = get_node("XP")
	self.XM = get_node("XM")
	self.YP = get_node("YP")
	self.YM = get_node("YM")
	self.ZP = get_node("ZP")
	self.ZM = get_node("ZM")
	
	self.XPH = get_node("XPH")
	self.XMH = get_node("XMH")
	self.YPH = get_node("YPH")
	self.YMH = get_node("YMH")
	self.ZPH = get_node("ZPH")
	self.ZMH = get_node("ZMH")
	
	self.planes = {
		Globals.PLANEID.XP: {
			"node": self.XP,
			"texture": null,
			"highlightnode": self.XPH,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.XM: {
			"node": self.XM,
			"texture": null,
			"highlightnode": self.XMH,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.YP: {
			"node": self.YP,
			"texture": null,
			"highlightnode": self.YPH,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.YM: {
			"node": self.YM,
			"texture": null,
			"highlightnode": self.YMH,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.ZP: {
			"node": self.ZP,
			"texture": null,
			"highlightnode": self.ZPH,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.ZM: {
			"node": self.ZM,
			"texture": null,
			"highlightnode": self.ZMH,
			"highlighted": false,
			"disabled": false
		}
	}

func get_id() -> int:
	return int(self.name)

func set_id(cubeid: int) -> void:
	self.name = str(cubeid)

func get_disabled(plane: int) -> bool:
	return planes[plane]["disabled"]

func set_disabled(plane: int, disabled: bool) -> void:
	planes[plane]["disabled"] = disabled
	if disabled:
		planes[plane]["node"].hide()
	else:
		planes[plane]["node"].show()

func get_data() -> Dictionary:
	return self.planes

func set_type_all(type: int) -> void:
	for plane in self.planes.values():
		plane["node"].texture = Globals.TEXTURES[type]
		plane["texture"] = type

func set_type(plane: int, type: int) -> void:
	self.planes[plane]["node"].texture = Globals.TEXTURES[type]
	self.planes[plane]["texture"] = type

func get_type(plane: int) -> int:
	return self.planes[plane]["texture"]

func set_position_grid(pos: Vector3) -> void:
	self.global_transform.origin.x = pos.x * 10
	self.global_transform.origin.y = pos.y * 10
	self.global_transform.origin.z = pos.z * 10

func get_position_grid() -> Vector3:
	return Vector3( self.global_transform.origin.x / 10,
					self.global_transform.origin.y / 10,
					self.global_transform.origin.z / 10 )

func set_face_highlight(plane: int, highlighted: bool) -> void:
	if highlighted:
		self.planes[plane]["highlightnode"].show()
	else:
		self.planes[plane]["highlightnode"].hide()
	self.planes[plane]["highlighted"] = highlighted

func set_all_face_highlight(highlighted: bool) -> void:
	for i in range(6):
		self.set_face_highlight(i, highlighted)

func get_face_highlight(plane: int) -> bool:
	return self.planes[plane]["highlighted"]


func _select_helper(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return ((event.button_index == BUTTON_LEFT) and (event.pressed == true))
	return false

func _on_XP_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.XP)

func _on_XM_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.XM)

func _on_YP_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.YP)

func _on_YM_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.YM)

func _on_ZP_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.ZP)

func _on_ZM_select(camera: Node, event: InputEvent, click_position: Vector3, click_normal: Vector3, shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), event, Globals.PLANEID.ZM)
