extends Spatial


var cubes: Array
var ents: Array
var toolSelected: int
var CubeScene: PackedScene
var cam: Camera
var camPivot: Spatial
var actionGizmo: Spatial
var currentSave: String
var levelName: String
var textureNode: Tree
var entityNode: Tree

signal grow_sidebar
signal shrink_sidebar


func _ready():
	self.cubes = []
	self.ents = []
	self.CubeScene = preload("res://scenes/editor/Cube.tscn")
	self.toolSelected = Globals.FIRSTTOOL
	self.actionGizmo = get_node("ActionGizmo")
	self.cam = get_parent().get_node("CameraPivot/Camera")
	self.camPivot = get_parent().get_node("CameraPivot")
	self.currentSave = ""
	self.levelName = ""
	self.textureNode = get_tree().get_nodes_in_group("TEXTURELIST")[0]
	self.entityNode = get_tree().get_nodes_in_group("ENTITYLIST")[0]
	
	self.add_cube(Vector3(), "builtin:white")

func _process(delta: float) -> void:
	if len(self.ents) > 0:
		var i: int = 0
		for ent in ents:
			if !is_instance_valid(ent["node"]):
				self.ents.remove(i)
			else:
				self.ents[i]["node"].name = "E" + str(i)
				i += 1


func add_cube(gridPos: Vector3, type: String) -> Spatial:
	var cube = self.CubeScene.instance()
	self.add_child(cube)
	self.cubes.append(cube)
	cube.__init(gridPos, type, len(self.cubes) - 1)
	return cube

func add_entity(pos: Vector3) -> void:
	var ent: Node = self.entityNode.ENTITIES[self.entityNode.get_selected_entity()].instance()
	ent.name = "E" + str(len(self.ents))
	ent.translate(pos)
	self.add_child(ent)
	self.ents.append({
		"node": ent,
		"ID": self.entityNode.get_selected_entity(),
		"posx": ent.global_transform.origin.x,
		"posy": ent.global_transform.origin.y,
		"posz": ent.global_transform.origin.z
	})

func add_entity_from_id(pos: Vector3, ID: String) -> void:
	var ent: Node = self.entityNode.ENTITIES[ID].instance()
	ent.name = "E" + str(len(self.ents))
	ent.translate(pos)
	self.add_child(ent)
	self.ents.append({
		"node": ent,
		"ID": ID,
		"posx": ent.global_transform.origin.x,
		"posy": ent.global_transform.origin.y,
		"posz": ent.global_transform.origin.z
	})

func add_entity_from_scene(pos: Vector3, scene: PackedScene) -> void:
	var ent: Spatial = scene.instance()
	ent.name = "E" + str(len(self.ents))
	ent.translate(pos)
	self.add_child(ent)
	self.ents.append({
		"node": ent,
		"ID": self.entityNode.get_entity_ID(scene),
		"posx": ent.global_transform.origin.x,
		"posy": ent.global_transform.origin.y,
		"posz": ent.global_transform.origin.z
	})

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

func get_placed_ent_pos(cubeid: int, plane: int) -> Vector3:
	var p: Vector3 = self.cubes[cubeid].get_position_grid()
	p.x *= 10
	p.y *= 10
	p.z *= 10
	p.y += 5
	return p

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
			print("Room.get_placed_cube_pos says how?")
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

func clear_entities() -> void:
	for ent in self.ents:
		self.remove_child(ent["node"])
		ent["node"].queue_free()
	self.ents = []

func serialize() -> String:
	var savedata: String = ""
	savedata += "{\"" + "VERSION" + "\": " + str(Globals.FILEFORMAT) + "}"
	var storedTextureIds: Array = []
	for cube in self.cubes:
		var dict: Dictionary = cube.get_data().duplicate(true)
		for i in range(6):
			var customTex: String = ""
			if dict[i]["texture"].split(":")[0] != "builtin":
				var ary: Array = dict[i]["texture"].split(":")
				var image: File = File.new()
				var ID: String = ""
				if len(ary) > 2:
					for item in ary.slice(1, len(ary) - 1):
						ID += item + ":"
					ID = ID.substr(0, len(ID) - 1)
				else:
					ID = ary[1]
				if !(ID in storedTextureIds):
					storedTextureIds.append(ID)
					image.open("user://.cache/" + ID, image.READ)
					customTex = Marshalls.raw_to_base64(image.get_buffer(image.get_len()))
					image.close()
					savedata += "\n{" + "\"T_" + ID + "\":\"" + customTex + "\"}"
	savedata += "\n"
	
	var storedEntIDs: Array = []
	for ent in self.ents:
		if ent["ID"].split(":")[0] != "builtin" and !(ent["ID"] in storedEntIDs):
			var scn: File = File.new()
			scn.open("user://.cache/" + ent["ID"].split(":")[-1], scn.READ)
			savedata += "{\"E_" + ent["ID"] + "\":\"" + Marshalls.raw_to_base64(scn.get_buffer(scn.get_len())) + "\"}\n"
			storedEntIDs.append(ent["ID"])
	
	for cube in self.cubes:
		var dict: Dictionary = cube.get_data().duplicate(true)
		for i in range(6):
			dict[i].erase("node")
			dict[i].erase("highlighted")
			dict[i].erase("highlightnode")
			
			if dict[i]["texture"].split(":")[0] != "builtin":
				var ary: Array = dict[i]["texture"].split(":")
				var ID: String = ""
				if len(ary) > 2:
					for item in ary.slice(1, len(ary) - 1):
						ID += item + ":"
					ID = ID.substr(0, len(ID) - 1)
				else:
					ID = ary[1]
				dict[i]["texdata"] = "T_" + ID
			else:
				dict[i]["texdata"] = "null"
		dict["posx"] = cube.get_position_grid().x
		dict["posy"] = cube.get_position_grid().y
		dict["posz"] = cube.get_position_grid().z
		savedata += to_json(dict) + "\n"
	
	for ent in self.ents.duplicate(true):
		ent.erase("node")
		savedata += to_json(ent) + "\n"
	
	return savedata

func clear() -> void:
	for i in range(len(self.cubes)):
		self.remove_child(self.cubes[i])
		self.cubes[i].queue_free()
		self.cubes[i] = null
	self.remove_null_cubes()
	self.clear_entities()
	self.add_cube(Vector3(), Globals.TEXTUREFALLBACK)

func save(levelName: String) -> void:
	self.levelName = levelName
	var save = File.new()
	self.currentSave = ""
	save.open("user://" + self.levelName + ".gpz", File.WRITE)
	self.currentSave = serialize()
	save.store_string(self.currentSave)
	save.close()

func load_texture(data: String, ID: String) -> void:
	var cache: File = File.new()
	var img: ImageTexture = ImageTexture.new()
	var i = Image.new()
	if ID.split(".")[-1] == "jpg":
		i.load_jpg_from_buffer(Marshalls.base64_to_raw(data))
	elif ID.split(".")[-1] == "png":
		i.load_png_from_buffer(Marshalls.base64_to_raw(data))
	cache.open("user://.cache/" + ID, cache.WRITE)
	cache.store_buffer(Marshalls.base64_to_raw(data))
	cache.close()
	i.resize(64, 64, Image.INTERPOLATE_NEAREST)
	img.create_from_image(i, 1)
	if !(Globals.CUSTOMTEXTUREID + ":" + ID in self.textureNode.TEXTURES):
		self.textureNode.add_item(Globals.CUSTOMTEXTUREID,
		ID.split("/")[-1].split(".")[0], ID,
		img)

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
			var textures64: Dictionary = {}
			self.currentSave = ""
			self.clear()
			self.remove_child(self.cubes[0])
			self.cubes[0].queue_free()
			self.cubes = []
			for data in contents:
				data = parse_json(data)
				if data != null:
					if data.keys()[0].substr(0,2) == "T_":
						textures64[data.keys()[0].substr(2,-1)] = data.values()[0]
						continue
					elif data.keys()[0].substr(0,2) == "E_":
						if !(data.keys()[0].substr(2) in self.entityNode.ENTITIES.keys()):
							var efile: File = File.new()
							efile.open("user://.cache/" + data.keys()[0].split(":")[-1], efile.WRITE)
							efile.store_buffer(Marshalls.base64_to_raw(data[data.keys()[0]]))
							efile.close()
							self.entityNode.add_item(
								Globals.CUSTOMID,
								data.keys()[0].split(":")[-1].split(".")[0],
								data.keys()[0].split(":")[-1],
								load("user://.cache/" + data.keys()[0].split(":")[-1]))
						continue
					elif data.keys()[0] == "0":
						var cube: Spatial = self.add_cube(Vector3(data["posx"], data["posy"], data["posz"]), Globals.TEXTUREFALLBACK)
						for i in range(6):
							if data[str(i)]["texdata"] != "null":
								var ary: Array = data[str(i)]["texture"].split(":")
								var ID: String = ""
								if len(ary) > 2:
									for item in ary.slice(1, len(ary) - 1):
										ID += item + ":"
									ID = ID.substr(0, len(ID) - 1)
								else:
									ID = ary[1]
								if !((Globals.CUSTOMID + ":" + ID) in self.textureNode.TEXTURES):
									self.load_texture(textures64[ID], ID)
								else:
									data[str(i)]["texdata"] = self.textureNode.get_texture(Globals.CUSTOMID + ":" + ID)
							cube.set_type(i, data[str(i)]["texture"])
							cube.set_disabled(i, data[str(i)]["disabled"])
					elif data.keys()[0] == "ID":
						self.add_entity_from_id(Vector3(int(data["posx"]), int(data["posy"]), int(data["posz"])), data["ID"])
			self.currentSave = self.serialize()
	save.close()
	get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text = path.split("/")[-1].split(".")[0]

func _on_face_selected(cubeid: int, plane: int, key: int) -> void:
	var clik: AudioStreamPlayer = get_parent().get_parent().get_node("Click")
	if !clik.get_disabled():
		clik.play()
	
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
			if key == BUTTON_LEFT:
				self.add_cube(self.get_placed_cube_pos(cubeid, plane), Globals.TEXTUREFALLBACK)
			elif key == BUTTON_RIGHT:
				if len(self.cubes) > 1:
					self.remove_child(self.cubes[cubeid])
					self.cubes[cubeid].queue_free()
					self.cubes[cubeid] = null
					self.remove_null_cubes()
		
		Globals.TOOL.TEXTURE:
			var tex: String = self.textureNode.get_selected_texture()
			if tex == "": tex = Globals.TEXTUREFALLBACK
			self.cubes[cubeid].set_type(plane, tex)
		
		Globals.TOOL.PLACEENTITY:
			if key == BUTTON_LEFT:
				var ent: String = self.entityNode.get_selected_entity()
				if ent != "" and plane == Globals.PLANEID.YP:
					self.add_entity(self.get_placed_ent_pos(cubeid, plane))
		_:
			print("Room._on_face_selected says how?")


func _on_Select_pressed():
	self.toolSelected = Globals.TOOL.SELECT
	self.emit_signal("shrink_sidebar")

func _on_VoxelBuild_pressed():
	self.toolSelected = Globals.TOOL.VOXEL
	self.unhighlight_all()
	self.emit_signal("shrink_sidebar")

func _on_VoxelTextured_pressed():
	self.toolSelected = Globals.TOOL.TEXTURE
	self.unhighlight_all()
	self.emit_signal("grow_sidebar")

func _on_PlaceEntity_pressed() -> void:
	self.toolSelected = Globals.TOOL.PLACEENTITY
	self.unhighlight_all()
	self.emit_signal("grow_sidebar")


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
