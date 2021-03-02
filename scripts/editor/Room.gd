extends Spatial


var cubes: Array
var cubeFacesSelected: Array
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
	self.cubeFacesSelected = []
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
	
	# warning-ignore:return_value_discarded
	self.add_cube(Vector3(), Globals.TEXTUREFALLBACK)

func _process(_delta: float) -> void:
	if len(self.ents) > 0:
		var i: int = 0
		for ent in ents:
			if !is_instance_valid(ent["node"]):
				self.ents.remove(i)
			else:
				self.ents[i]["node"].name = "E" + str(i)
				i += 1
	if Input.is_action_just_pressed("editor_add_cube"):
		for cubeid in range(len(cubeFacesSelected)):
			var planes = self.cubeFacesSelected[cubeid].keys()
			self.cubes[cubeid].set_all_face_highlight(false)
			self.cubeFacesSelected[cubeid] = {}
			for plane in planes:
				var cube = self.add_cube_if_empty(self.get_placed_cube_pos(cubeid, plane), Globals.TEXTUREFALLBACK)
				if cube != null:
					cube.set_face_highlight(plane, true)
					self.cubeFacesSelected[cube.get_id()][plane] = true
	elif Input.is_action_just_pressed("editor_subtract_cube"):
		var cubeid: int = 0
		while cubeid < len(self.cubes):
			var planes = self.cubeFacesSelected[cubeid].keys()
			if len(planes) > 0:
				for plane in planes:
					var cube = self.get_cube_at_grid_pos(self.get_opposite_placed_cube_pos(cubeid, plane))
					if cube != null:
						cube.set_face_highlight(plane, true)
						self.cubeFacesSelected[cube.get_id()][plane] = true
				if len(self.cubes) > 1:
					self.remove_cube(cubeid)
				else:
					cubeid += 1
			else:
				cubeid += 1
			#for plane in planes:
			#	cube.set_face_highlight(plane, true)
			#	self.cubeFacesSelected[cube.get_id()][plane] = true

func add_cube(gridPos: Vector3, type: String) -> Spatial:
	var cube = self.CubeScene.instance()
	self.add_child(cube)
	self.cubes.append(cube)
	self.cubeFacesSelected.append({})
	cube.__init(gridPos, type, len(self.cubes) - 1)
	self.update_surrounding_cull_faces(cube.get_id(), gridPos)
	return cube

func add_cube_if_empty(gridPos: Vector3, type: String) -> Spatial:
	# TODO: add cube only if unoccupied, otherwise there may be several cubes in one position
	if (self.get_cube_at_grid_pos(gridPos) == null):
		return self.add_cube(gridPos, type)
	return null

func remove_cube(cubeid: int) -> void:
	if len(self.cubes) > 1:
		self.update_empty_surrounding_cull_faces(self.cubes[cubeid].get_position_grid())
		self.remove_child(self.cubes[cubeid])
		self.cubes[cubeid].queue_free()
		self.cubes[cubeid] = null
		self.cubeFacesSelected[cubeid] = {}
		self.remove_null_cubes()

func update_surrounding_cull_faces(cubeid: int, gridPos: Vector3) -> void:
	var cube = self.cubes[cubeid]
	var XM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.XM))
	var XP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.XP))
	var YM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.YM))
	var YP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.YP))
	var ZM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.ZM))
	var ZP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.ZP))
	if XM != null:
		XM.set_disabled(Globals.PLANEID.XP, true)
		cube.set_disabled(Globals.PLANEID.XM, true)
	if XP != null:
		XP.set_disabled(Globals.PLANEID.XM, true)
		cube.set_disabled(Globals.PLANEID.XP, true)
	if YM != null:
		YM.set_disabled(Globals.PLANEID.YP, true)
		cube.set_disabled(Globals.PLANEID.YM, true)
	if YP != null:
		YP.set_disabled(Globals.PLANEID.YM, true)
		cube.set_disabled(Globals.PLANEID.YP, true)
	if ZM != null:
		ZM.set_disabled(Globals.PLANEID.ZP, true)
		cube.set_disabled(Globals.PLANEID.ZM, true)
	if ZP != null:
		ZP.set_disabled(Globals.PLANEID.ZM, true)
		cube.set_disabled(Globals.PLANEID.ZP, true)

func update_empty_surrounding_cull_faces(gridPos: Vector3) -> void:
	var XM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.XM))
	var XP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.XP))
	var YM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.YM))
	var YP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.YP))
	var ZM = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.ZM))
	var ZP = self.get_cube_at_grid_pos(Globals.GET_OFFSET_ON_AXIS(gridPos, Globals.PLANEID.ZP))
	if XM != null:
		XM.set_disabled(Globals.PLANEID.XP, false)
	if XP != null:
		XP.set_disabled(Globals.PLANEID.XM, false)
	if YM != null:
		YM.set_disabled(Globals.PLANEID.YP, false)
	if YP != null:
		YP.set_disabled(Globals.PLANEID.YM, false)
	if ZM != null:
		ZM.set_disabled(Globals.PLANEID.ZP, false)
	if ZP != null:
		ZP.set_disabled(Globals.PLANEID.ZM, false)

func add_entity(pos: Vector3) -> void:
	self.add_entity_from_id(pos, self.entityNode.get_selected_entity())

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

func get_player_start() -> Array:
	for ent in self.ents:
		if ent["ID"] == "builtin:" + Globals.PLAYER_START:
			return [true, ent["posx"], ent["posy"], ent["posz"]]
	return [false]

func unhighlight_all() -> void:
	for cube in self.cubes:
		if cube != null:
			cube.set_all_face_highlight(false)
	for i in range(0, len(self.cubes)):
		self.cubeFacesSelected[i] = {}
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

func get_cube_at_grid_pos(gridPos: Vector3):
	for cube in self.cubes:
		if cube.get_position_grid() == gridPos:
			return cube
	return null

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

func get_opposite_placed_cube_pos(cubeid: int, plane: int) -> Vector3:
	var cubePosGrid: Vector3 = self.cubes[cubeid].get_position_grid()
	match plane:
		Globals.PLANEID.XP:
			cubePosGrid.x -= 1
		Globals.PLANEID.XM:
			cubePosGrid.x += 1
		Globals.PLANEID.YP:
			cubePosGrid.y -= 1
		Globals.PLANEID.YM:
			cubePosGrid.y += 1
		Globals.PLANEID.ZP:
			cubePosGrid.z -= 1
		Globals.PLANEID.ZM:
			cubePosGrid.z += 1
		_:
			print("Room.get_opposite_placed_cube_pos says how?")
	return cubePosGrid

func remove_null_cubes() -> void:
	var i: int = 0
	while i < len(self.cubes):
		var cube: Spatial = self.cubes[i]
		if cube == null:
			self.cubes.remove(i)
			self.cubeFacesSelected.remove(i)
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
					# warning-ignore:return_value_discarded
					image.open("user://.cache/" + ID, image.READ)
					customTex = Marshalls.raw_to_base64(image.get_buffer(image.get_len()))
					image.close()
					savedata += "\n{" + "\"T_" + ID + "\":\"" + customTex + "\"}"
	savedata += "\n"
	
	var storedEntIDs: Array = []
	for ent in self.ents:
		if ent["ID"].split(":")[0] != "builtin" and !(ent["ID"] in storedEntIDs):
			var scn: File = File.new()
			# warning-ignore:return_value_discarded
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
	
	var lightData: Panel = get_parent().get_parent().get_node("Menu/Control/LightPanel")
	savedata += "{" + \
					"\"P_LIGHT\":{" + \
						"\"sunx\":"       + str(int(lightData.xs.value))  + \
						",\"suny\":"      + str(int(lightData.ys.value))  + \
						",\"sunstr\":"    + str(int(lightData.sns.value)) + \
						",\"gistr\":"     + str(int(lightData.gis.value)) + \
						",\"sunenable\":" + str(lightData.sunBtn.pressed).to_lower() + \
						",\"gienable\":"  + str(lightData.giBtn.pressed).to_lower()  + \
					"}" + \
				"}\n"
	
	return savedata

func clear() -> void:
	for i in range(len(self.cubes)):
		self.remove_child(self.cubes[i])
		self.cubes[i].queue_free()
		self.cubes[i] = null
	self.remove_null_cubes()
	self.clear_entities()
	# warning-ignore:return_value_discarded
	self.add_cube(Vector3(), Globals.TEXTUREFALLBACK)
	get_parent().get_parent().get_node("Menu/Control/LightPanel").__init(false, true, 0, 0, 100, 100)

func save(levelname: String) -> void:
	self.levelName = levelname
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
	# warning-ignore:return_value_discarded
	cache.open("user://.cache/" + ID, cache.WRITE)
	cache.store_buffer(Marshalls.base64_to_raw(data))
	cache.close()
	i.resize(64, 64, Image.INTERPOLATE_NEAREST)
	img.create_from_image(i, 1)
	if !(Globals.CUSTOMID + ":" + ID in self.textureNode.TEXTURES):
		self.textureNode.add_item(Globals.CUSTOMID,
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
							# warning-ignore:return_value_discarded
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
					elif data.keys()[0].substr(0,2) == "P_":
						if data.keys()[0] == "P_LIGHT":
							var lightData: Panel = get_parent().get_parent().get_node("Menu/Control/LightPanel")
							lightData.__init(false, true, 0, 0, 100, 100)
							lightData.xs.value = int(data["P_LIGHT"]["sunx"])
							lightData.ys.value = int(data["P_LIGHT"]["suny"])
							lightData.sns.value = int(data["P_LIGHT"]["sunstr"])
							lightData.gis.value = int(data["P_LIGHT"]["gistr"])
							lightData.sunBtn.pressed = bool(data["P_LIGHT"]["sunenable"])
							lightData.giBtn.pressed = bool(data["P_LIGHT"]["gienable"])
							lightData.update()
			self.currentSave = self.serialize()
	save.close()
	get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text = path.split("/")[-1].split(".")[0]

func export_to_vmf(filenam: String) -> void:
	var vmf = VMF.new()
	for cube in self.cubes:
		var cubepos = cube.get_position_grid() * 64
		cubepos.x = cubepos.x + 32
		cubepos.y = cubepos.y - 32
		cubepos.z = cubepos.z + 32
		var block = VMF.Block.new(cubepos, Vector3(64, 64, 64))
		var dirs = [Vector3.FORWARD, Vector3.BACK, Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT]
		for plane in range(6):
			if cube.get_disabled(plane):
				block.set_material_side(vmf.COMMON_MATERIALS.TOOLS_TOOLSNODRAW, dirs[plane])
				continue
			var planeTexture: String = cube.get_type(plane)
			if planeTexture == "builtin:white":
				block.set_material_side("TILE/WHITE_WALL_TILE001A", dirs[plane])
			elif planeTexture == "builtin:black":
				block.set_material_side("METAL/BLACK_WALL_METAL_002D", dirs[plane])
			elif planeTexture == "builtin:dev_orange":
				block.set_material_side(vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A, dirs[plane])
			elif planeTexture == "builtin:dev_grey":
				block.set_material_side(vmf.COMMON_MATERIALS.DEV_MEASUREWALL01D, dirs[plane])
		vmf.add_solid(block.brush)
	for entity in self.ents:
		if entity["ID"] == "builtin:" + Globals.PLAYER_START:
			VMF.Entities.Common.InfoPlayerStartEntity.new(vmf, self.get_translated_entity_position_in_vmf(entity["posx"], entity["posy"], entity["posz"]))
		elif entity["ID"] == "builtin:omnilight":
			VMF.Entities.Common.LightEntity.new(vmf, self.get_translated_entity_position_in_vmf(entity["posx"], entity["posy"] + 5, entity["posz"]))
	vmf.write_vmf(filenam)

func get_translated_entity_position_in_vmf(x: float, y: float, z: float) -> Vector3:
	return Vector3((x / 10) * 64 + 32, (y / 10) * 64 - 32, (z / 10) * 64 + 32)

func _on_face_selected(cubeid: int, plane: int, key: int, drag: bool) -> void:
	var clik: AudioStreamPlayer = get_parent().get_parent().get_node("Click")
	if !clik.get_disabled() and not drag:
		clik.play()
	
	if Globals.PLAY_MODE:
		return
	
	match self.toolSelected:
		
		Globals.TOOL.SELECT:
			if key == BUTTON_LEFT and not drag:
				var highlight: bool = !self.cubes[cubeid].get_face_highlight(plane)
				self.unhighlight_all()
				self.cubes[cubeid].set_face_highlight(plane, highlight)
				if highlight:
					self.cubeFacesSelected[cubeid][plane] = true
					#self.set_actionGizmo_pos(cubeid, plane)
					#self.actionGizmo.show()
			elif key == BUTTON_RIGHT and not drag:
				var highlighted: bool = self.cubes[cubeid].get_face_highlight(plane)
				if !highlighted:
					self.cubes[cubeid].set_face_highlight(plane, true)
					self.cubeFacesSelected[cubeid][plane] = true
					#self.actionGizmo.show()
					#self.set_actionGizmo_pos(cubeid, plane)
				else:
					self.cubes[cubeid].set_face_highlight(plane, false)
					self.cubeFacesSelected[cubeid].erase(plane)
					#self.actionGizmo.hide()
			elif key == BUTTON_RIGHT and drag:
				var highlighted: bool = self.cubes[cubeid].get_face_highlight(plane)
				if !highlighted:
					self.cubes[cubeid].set_face_highlight(plane, true)
					self.cubeFacesSelected[cubeid][plane] = true
					#self.actionGizmo.show()
					#self.set_actionGizmo_pos(cubeid, plane)
		
		Globals.TOOL.VOXEL:
			if key == BUTTON_LEFT and not drag:
				# warning-ignore:return_value_discarded
				self.add_cube(self.get_placed_cube_pos(cubeid, plane), Globals.TEXTUREFALLBACK)
			elif key == BUTTON_RIGHT and not drag:
				self.remove_cube(cubeid)
		
		Globals.TOOL.TEXTURE:
			if key == BUTTON_LEFT and not drag:
				pass # TODO: add context menu here
			elif key == BUTTON_RIGHT:
				var tex: String = self.textureNode.get_selected_texture()
				if tex == "":
					tex = Globals.TEXTUREFALLBACK
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


func _on_ArrowX_input_event(_camera, _event, _click_position, _click_normal, _shape_idx):
	pass

func _on_ArrowY_input_event(_camera, _event, _click_position, _click_normal, _shape_idx):
	pass

func _on_ArrowZ_input_event(_camera, _event, _click_position, _click_normal, _shape_idx):
	pass
