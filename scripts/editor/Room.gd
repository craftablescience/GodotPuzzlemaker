extends Spatial


var cubes: Array
var toolSelected: int
var CubeScene: PackedScene
var cam: Camera
var camPivot: Spatial
var actionGizmo: Spatial


func _ready():
	self.cubes = []
	self.CubeScene = preload("res://scenes/editor/Cube.tscn")
	self.toolSelected = Globals.FIRSTTOOL
	self.actionGizmo = get_node("ActionGizmo")
	self.cam = get_parent().get_node("CameraPivot/Camera")
	self.camPivot = get_parent().get_node("CameraPivot")
	
	self.add_cube(Vector3(), Globals.TEXTURETYPE.WHITE)

func _process(_delta: float) -> void:
	var camPivotRot: Vector3 = self.camPivot.global_transform.basis.get_euler()
	var xrot: float = rad2deg(camPivotRot.x)
	

func add_cube(gridPos: Vector3, type: int):
	var cube = self.CubeScene.instance()
	cube.__init(gridPos, type, len(self.cubes))
	
	self.add_child(cube)
	self.cubes.append(cube)

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

func _on_face_selected(cubeid: int, plane: int, key: int) -> void:
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
