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
var textureNode: Tree


func __init(pos: Vector3, type: String, id: int):
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
	self.load_textures()
	self.set_type_all(type)
	self.set_position_grid(pos)
	self.set_id(id)

func load_textures() -> void:
	self.textureNode = get_tree().get_nodes_in_group("TEXTURELIST")[0]

func get_id() -> int:
	return int(self.name)

func set_id(cubeID: int) -> void:
	self.name = str(cubeID)

func get_disabled(plane: int) -> bool:
	return self.planes[plane]["disabled"]

func set_disabled(plane: int, disabled: bool) -> void:
	self.planes[plane]["disabled"] = disabled
	if disabled:
		self.planes[plane]["node"].hide()
	else:
		self.planes[plane]["node"].show()

func get_plane(planeid: int):
	match planeid:
		Globals.PLANEID.XP:
			return self.XP
		Globals.PLANEID.XM:
			return self.XM
		Globals.PLANEID.YP:
			return self.YP
		Globals.PLANEID.YM:
			return self.YM
		Globals.PLANEID.ZP:
			return self.ZP
		Globals.PLANEID.ZM:
			return self.ZM
		_:
			print("Room.get_plane says how?")

# warning-ignore:shadowed_variable
func set_data(planes: Dictionary) -> void:
	for i in range(6):
		self.set_type(i, planes[i]["texture"])
		self.set_disabled(i, planes[i]["disabled"])

func get_data() -> Dictionary:
	return self.planes

func set_type_all(type: String) -> void:
	for i in Globals.PLANEID.values():
		self.set_type(i, type)

func set_type(plane: int, type: String) -> void:
	self.planes[plane]["node"].texture = self.textureNode.get_texture(type)
	self.planes[plane]["texture"] = type

func get_type(plane: int) -> Array:
	return self.planes[plane]["texture"]

func set_position_grid(pos: Vector3) -> void:
	self.transform.origin.x = pos.x * 10
	self.transform.origin.y = pos.y * 10
	self.transform.origin.z = pos.z * 10

func get_position_grid() -> Vector3:
	return Vector3( self.transform.origin.x / 10,
					self.transform.origin.y / 10,
					self.transform.origin.z / 10 )

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
	return  (event is InputEventMouseButton) and \
			(((event.button_index == BUTTON_LEFT) \
			or (event.button_index == BUTTON_RIGHT)) \
			and (event.pressed == true))

func _on_XP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.XP, event.button_index)

func _on_XM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.XM, event.button_index)

func _on_YP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.YP, event.button_index)

func _on_YM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.YM, event.button_index)

func _on_ZP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.ZP, event.button_index)

func _on_ZM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if _select_helper(event):
		get_parent()._on_face_selected(self.get_id(), Globals.PLANEID.ZM, event.button_index)
