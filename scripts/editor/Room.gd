extends Spatial


var cubes: Array
var highlightedFaces: Dictionary
var toolSelected: int
var CubeScene: PackedScene
var actionGizmo: Spatial


func _ready():
	self.cubes = []
	self.highlightedFaces = {}
	self.CubeScene = preload("res://scenes/editor/Cube.tscn")
	self.toolSelected = Globals.FIRSTTOOL
	self.actionGizmo = get_node("ActionGizmo")
	
	self.add_cube(Vector3(), Globals.TEXTURETYPE.WHITE)

func add_cube(pos: Vector3, type: int):
	var cube = self.CubeScene.instance()
	cube.set_type_all(type)
	cube.set_position_grid(pos)
	cube.set_id(len(self.cubes))
	self.highlightedFaces[cube.get_id()] = {}
	self.add_child(cube)
	self.cubes.append(cube)

func unhighlight_all() -> void:
	for cube in self.cubes:
		cube.set_all_face_highlight(false)
		self.highlightedFaces[cube.get_id()] = {}
	self.actionGizmo.hide()

func set_actionGizmo_pos(cubeid: int, plane: int):
	var cubePos: Vector3 = Vector3( cubes[cubeid].global_transform.origin.x,
									cubes[cubeid].global_transform.origin.y,
									cubes[cubeid].global_transform.origin.z )
	match (plane):
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


func _on_face_selected(cubeid: int, event: InputEventMouseButton, plane: int) -> void:
	var highlighted = self.cubes[cubeid].get_face_highlight(plane)
	
	if self.toolSelected == Globals.TOOL.SELECT:
		if !highlighted:
			self.unhighlight_all()
			self.cubes[cubeid].set_face_highlight(plane, true)
			self.highlightedFaces[cubeid][plane] = true
			self.actionGizmo.show()
			self.set_actionGizmo_pos(cubeid, plane)
			print("Unhighlighted all and highlighted: " + str(cubeid) + ":" + str(plane) + ":" + str(highlighted))
		if highlighted:
			self.cubes[cubeid].set_face_highlight(plane, false)
			self.highlightedFaces[cubeid][plane] = false
			self.actionGizmo.hide()
			print("Unhighlighted: " + str(cubeid) + ":" + str(plane) + ":" + str(highlighted))
	else:
		self.highlightedFaces[cubeid].erase(plane)

func _on_Select_pressed():
	self.toolSelected = Globals.TOOL.SELECT

func _on_VoxelBuild_pressed():
	self.toolSelected = Globals.TOOL.VOXELADD

func _on_VoxelDelete_pressed():
	self.toolSelected = Globals.TOOL.VOXELSUBTRACT

func _on_VoxelTextured_pressed():
	self.toolSelected = Globals.TOOL.TEXTURE
