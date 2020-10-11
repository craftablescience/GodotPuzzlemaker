extends Spatial


var cubes: Array
var toolSelected: int
var CubeScene: PackedScene
var cam: Camera
var camPivot: Spatial
var actionGizmo: Spatial
var currentSave: String
var levelName: String


func _ready():
	self.cubes = []
	self.CubeScene = preload("res://scenes/editor/Cube.tscn")
	self.toolSelected = Globals.FIRSTTOOL
	self.actionGizmo = get_node("ActionGizmo")
	self.cam = get_parent().get_node("CameraPivot/Camera")
	self.camPivot = get_parent().get_node("CameraPivot")
	self.currentSave = ""
	self.levelName = ""
	
	self.add_cube(Vector3(), Globals.TEXTURETYPE.WHITE)

func _process(_delta: float) -> void:
	var camPivotRot: Vector3 = self.camPivot.global_transform.basis.get_euler()
	var xrot: float = rad2deg(camPivotRot.x)
	

func add_cube(gridPos: Vector3, type: int) -> Spatial:
	var cube = self.CubeScene.instance()
	cube.__init(gridPos, type, len(self.cubes))
	
	self.add_child(cube)
	self.cubes.append(cube)
	return cube

func unhighlight_all() -> void:
	for cube in self.cubes:
		if cube != null:
			cube.set_all_face_highlight(false)
	self.actionGizmo.hide()

func set_actionGizmo_pos(cubeid: int, plane: int):
	var cubePos: Vector3 = Vector3( cubes[cubeid].global_transform.origin.x,
									cubes[cubeid].global_transform.origin.y,
									cubes[cubeid].global_transform.origin.z )
	match plane:
		Globals.PLANEID.XP:
			cubePos.x += 5
		Globals.PLANEID.XM:
			cubePos.x -= 5
		Globals.PLANEID.YP:
			cubePos.y += 5
		Globals.PLANEID.YM:
			cubePos.y -= 5
		Globals.PLANEID.ZP:
			cubePos.z += 5
		Globals.PLANEID.ZM:
			cubePos.z -= 5
		_:
			print("Room.set_actionGizmo_pos says how?")
	self.actionGizmo.translation = cubePos

func get_placed_cube_pos(cubeid: int, plane: int) -> Vector3:
	var cubePosGrid: Vector3 = self.cubes[cubeid].get_position_grid()
	match plane:
		Globals.PLANEID.XP:
			cubePosGrid.x += 1
		Globals.PLANEID.XM:
			cubePosGrid.x -= 1
		Globals.PLANEID.YP:
			cubePosGrid.y += 1
		Globals.PLANEID.YM:
			cubePosGrid.y -= 1
		Globals.PLANEID.ZP:
			cubePosGrid.z += 1
		Globals.PLANEID.ZM:
			cubePosGrid.z -= 1
		_:
			print("Room.add_cube_relative says how?")
	return cubePosGrid

func remove_null_cubes() -> void:
	var i: int = 0
	while i < len(self.cubes):
		var cube: Spatial = self.cubes[i]
		if cube == null:
			self.cubes.remove(i)
		else:
			self.cubes[i].set_id(i)
			i += 1

func serialize() -> String:
	var savedata: String = ""
	savedata += "{\"" + "VERSION" + "\": " + str(Globals.FILEFORMAT) + "}\n"
	for cube in self.cubes:
		var dict: Dictionary = cube.get_data().duplicate(true)
		for i in range(6):
			dict[i].erase("node")
			dict[i].erase("highlighted")
			dict[i].erase("highlightnode")
		dict["posx"] = cube.get_position_grid().x
		dict["posy"] = cube.get_position_grid().y
		dict["posz"] = cube.get_position_grid().z
		savedata += to_json(dict) + "\n"
		print(len(self.cubes))
	return savedata

func clear() -> void:
	for i in range(len(self.cubes)):
		self.remove_child(self.cubes[i])
		self.cubes[i].queue_free()
		self.cubes[i] = null
	self.remove_null_cubes()
	self.add_cube(Vector3(), Globals.TEXTURETYPE.WHITE)

func save(levelName: String) -> void:
	self.levelName = levelName
	var save = File.new()
	self.currentSave = ""
	save.open("user://" + self.levelName + ".gpz", File.WRITE)
	self.currentSave = serialize()
	save.store_string(self.currentSave)
	save.close()

func load_save(path: String) -> void:
	var save = File.new()
	save.open(path, File.READ)
	var contents: Array = save.get_as_text().split("\n")
	if contents != null:
		if int(parse_json(contents[0])["VERSION"]) < Globals.FILEFORMAT:
			get_parent().get_parent().get_node("Menu/Control/LoadFileFormatLow").popup_centered()
		elif int(parse_json(contents[0])["VERSION"]) > Globals.FILEFORMAT:
			get_parent().get_parent().get_node("Menu/Control/LoadFileFormatHigh").popup_centered()
		else:
			contents.remove(0)
			self.currentSave = ""
			self.clear()
			self.remove_child(self.cubes[0])
			self.cubes[0].queue_free()
			self.cubes = []
			for data in contents:
				data = parse_json(data)
				if data != null:
					var cube: Spatial = self.add_cube(Vector3(data["posx"], data["posy"], data["posz"]), Globals.TEXTURETYPE.WHITE)
					for i in range(6):
						cube.set_type(i, data[str(i)]["texture"])
						cube.set_disabled(i, data[str(i)]["disabled"])
			self.currentSave = self.serialize()
	save.close()

func _on_face_selected(cubeid: int, plane: int, key: int) -> void:
	get_parent().get_parent().get_node("Click").play()
	
	match self.toolSelected:
		
		Globals.TOOL.SELECT:
			if key == BUTTON_LEFT:
				var highlight: bool = !self.cubes[cubeid].get_face_highlight(plane)
				self.unhighlight_all()
				self.cubes[cubeid].set_face_highlight(plane, highlight)
				if highlight:
					self.set_actionGizmo_pos(cubeid, plane)
					self.actionGizmo.show()
			elif key == BUTTON_RIGHT:
				var highlighted: bool = self.cubes[cubeid].get_face_highlight(plane)
				if !highlighted:
					self.cubes[cubeid].set_face_highlight(plane, true)
					self.actionGizmo.show()
					self.set_actionGizmo_pos(cubeid, plane)
				else:
					self.cubes[cubeid].set_face_highlight(plane, false)
					self.actionGizmo.hide()
		
		Globals.TOOL.VOXEL:
			if (key == BUTTON_LEFT):
				self.add_cube(self.get_placed_cube_pos(cubeid, plane), Globals.TEXTURETYPE.WHITE)
			elif (key == BUTTON_RIGHT):
				if len(self.cubes) > 1:
					self.remove_child(self.cubes[cubeid])
					self.cubes[cubeid].queue_free()
					self.cubes[cubeid] = null
					self.remove_null_cubes()
		
		Globals.TOOL.TEXTURE:
			var currentTexture: int = 0
			if key == BUTTON_LEFT:
				currentTexture = Globals.TEXTURETYPE.WHITE
			elif key == BUTTON_RIGHT:
				currentTexture = Globals.TEXTURETYPE.BLACK
			self.cubes[cubeid].set_type(plane, currentTexture)
		_:
			print("Room._on_face_selected says how?")


func _on_Select_pressed():
	self.toolSelected = Globals.TOOL.SELECT

func _on_VoxelBuild_pressed():
	self.toolSelected = Globals.TOOL.VOXEL
	self.unhighlight_all()

func _on_VoxelTextured_pressed():
	self.toolSelected = Globals.TOOL.TEXTURE
	self.unhighlight_all()


func _on_ArrowX_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_ArrowY_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_ArrowZ_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_MoveXY_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_MoveYZ_input_event(camera, event, click_position, click_normal, shape_idx):
	pass

func _on_MoveXZ_input_event(camera, event, click_position, click_normal, shape_idx):
	pass
