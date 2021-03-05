extends Spatial


var XP: MeshInstance
var XM: MeshInstance
var YP: MeshInstance
var YM: MeshInstance
var ZP: MeshInstance
var ZM: MeshInstance

var planes: Dictionary
var textureNode: Tree


enum FACE_SELECTION_MODE {
	NONE,
	CLICK,
	DRAG
}


func __init(pos: Vector3, type: String, id: int):
	self.XP = get_node("XP")
	self.XM = get_node("XM")
	self.YP = get_node("YP")
	self.YM = get_node("YM")
	self.ZP = get_node("ZP")
	self.ZM = get_node("ZM")
	
	self.planes = {
		Globals.PLANEID.XP: {
			"node": self.XP,
			"texture": null,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.XM: {
			"node": self.XM,
			"texture": null,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.YP: {
			"node": self.YP,
			"texture": null,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.YM: {
			"node": self.YM,
			"texture": null,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.ZP: {
			"node": self.ZP,
			"texture": null,
			"highlighted": false,
			"disabled": false
		},
		Globals.PLANEID.ZM: {
			"node": self.ZM,
			"texture": null,
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
			assert(false, "Room.get_plane says how?")

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
	self.planes[plane]["node"].material_override.albedo_texture = self.textureNode.get_texture(type)
	self.planes[plane]["texture"] = type

func get_type(plane: int) -> String:
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
		self.planes[plane]["node"].material_override.albedo_color = Color.cadetblue
	else:
		self.planes[plane]["node"].material_override.albedo_color = Color.white
	self.planes[plane]["highlighted"] = highlighted

func set_all_face_highlight(highlighted: bool) -> void:
	for i in range(6):
		self.set_face_highlight(i, highlighted)

func get_face_highlight(plane: int) -> bool:
	return self.planes[plane]["highlighted"]

func _select_helper(event: InputEvent) -> int:
	if event is InputEventMouseButton and ((event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed == true):
		return FACE_SELECTION_MODE.CLICK
	elif event is InputEventMouseMotion and (Input.is_action_pressed("left_click") or Input.is_action_pressed("right_click")):
		return FACE_SELECTION_MODE.DRAG
	else:
		return FACE_SELECTION_MODE.NONE

func _on_select(plane: int, event: InputEvent):
	var selectHelper: int = self._select_helper(event)
	match (selectHelper):
		FACE_SELECTION_MODE.NONE:
			return
		FACE_SELECTION_MODE.CLICK:
			get_parent()._on_face_selected(self.get_id(), plane, event.button_index, false)
		FACE_SELECTION_MODE.DRAG:
			var btn: int
			if Input.is_action_pressed("left_click"):
				btn = BUTTON_LEFT
			elif Input.is_action_pressed("right_click"):
				btn = BUTTON_RIGHT
			else:
				return
			get_parent()._on_face_selected(self.get_id(), plane, btn, true)
		_:
			assert(false, "Cube._on_select says how?")

func _on_XP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.XP, event)

func _on_XM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.XM, event)

func _on_YP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.YP, event)

func _on_YM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.YM, event)

func _on_ZP_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.ZP, event)

func _on_ZM_select(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	self._on_select(Globals.PLANEID.ZM, event)
