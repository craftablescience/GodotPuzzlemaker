extends Spatial


export(NodePath) var tool_select: NodePath
onready var tool_select_btn: Button = get_node(tool_select)
export(NodePath) var tool_build: NodePath
onready var tool_build_btn: Button = get_node(tool_build)
export(NodePath) var tool_texture: NodePath
onready var tool_texture_btn: Button = get_node(tool_texture)
export(NodePath) var tool_placeentity: NodePath
onready var tool_placeentity_btn: Button = get_node(tool_placeentity)
export(NodePath) var tool_connection: NodePath
onready var tool_connection_btn: Button = get_node(tool_connection)
export(NodePath) var add_button_path: NodePath
onready var add_button: Button = get_node(add_button_path)
export(NodePath) var remove_button_path: NodePath
onready var remove_button: Button = get_node(remove_button_path)
export(NodePath) var search_box_path: NodePath
onready var search_box: LineEdit = get_node(search_box_path)

var cubes: Array
var cubeFacesSelected: Array
var ents: Array
var toolSelected: int
var currentEntID: int
var CubeScene: PackedScene
var cam: Camera
var camPivot: Spatial
var actionGizmo: Spatial
var currentSave: String
var levelName: String

signal grow_sidebar
signal shrink_sidebar
signal rebuild_connectionlist(removed_ent_ids)


func __init():
	self.cubes = []
	self.cubeFacesSelected = []
	self.ents = []
	self.currentEntID = 0
	self.CubeScene = preload("res://scenes/editor/Cube.tscn")
	self.toolSelected = Globals.FIRSTTOOL
	self.actionGizmo = get_node("ActionGizmo")
	self.cam = get_parent().get_node("CameraPivot/Camera")
	self.camPivot = get_parent().get_node("CameraPivot")
	self.currentSave = ""
	self.levelName = ""
	
	# warning-ignore:return_value_discarded
	self.add_cube(Vector3(), Globals.TEXTUREFALLBACK)

func _process(_delta: float) -> void:
	if len(self.ents) > 0:
		var i: int = 0
		for ent in ents:
			if !is_instance_valid(ent["node"]):
				self.ents.remove(i)
				self.remove_null_ents()
			else:
				self.ents[i]["node"].name = "E" + str(i)
				i += 1
	if Input.is_action_just_pressed("editor_add_cube"):
		for cubeid in range(len(cubeFacesSelected)):
			var planes = self.cubeFacesSelected[cubeid].keys()
			self.cubes[cubeid].set_all_face_highlight(false)
			self.cubeFacesSelected[cubeid] = {}
			var tex: String = PackLoader.get_selected_texture()
			if tex == "":
				tex = Globals.TEXTUREFALLBACK
			for plane in planes:
				var cube = self.add_cube_if_empty(self.get_placed_cube_pos(cubeid, plane), tex)
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
	self.add_entity_from_id(pos, PackLoader.get_selected_entity())

func add_entity_from_id(pos: Vector3, ID: String) -> void:
	var ent: Node = PackLoader.entityNode.ENTITIES[ID].instance()
	ent.name = "E" + str(self.currentEntID)
	ent.set_logic_id(self.currentEntID)
	ent._editor_set_room(self)
	ent._editor_set_connection_list(get_parent().get_parent().get_node("Menu/Control/ContextPanel/TabContainer/Connections/List"))
	ent.translate(pos)
	self.add_child(ent)
	self.ents.append({
		"node": ent,
		"ID": ID,
		"logicID": self.currentEntID,
		"posx": ent.global_transform.origin.x,
		"posy": ent.global_transform.origin.y,
		"posz": ent.global_transform.origin.z
	})
	self.currentEntID += 1

func add_entity_from_scene(pos: Vector3, scene: PackedScene) -> void:
	var ent: Spatial = scene.instance()
	ent.name = "E" + str(self.currentEntID)
	ent.set_logic_id(self.currentEntID)
	ent.translate(pos)
	self.add_child(ent)
	self.ents.append({
		"node": ent,
		"ID": PackLoader.entityNode.get_entity_ID(scene),
		"logicID": self.currentEntID,
		"posx": ent.global_transform.origin.x,
		"posy": ent.global_transform.origin.y,
		"posz": ent.global_transform.origin.z
	})
	LogicManager.add_logic_entity(self.currentEntID, ent)
	self.currentEntID += 1

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

func remove_null_ents() -> void:
	var ary: Array = []
	var i: int = 0
	for ent in self.ents:
		if is_instance_valid(ent["node"]):
			ent["node"].name = "E" + str(i)
			i += 1
		else:
			ary.append(ent["logicID"])
			ents.remove(i)
	self.emit_signal("rebuild_connectionlist", ary)

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
			if dict[i]["texture"].split(":")[0] != "builtin" and dict[i]["texture"].split(":")[0] != "default":
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
			
			if dict[i]["texture"].split(":")[0] != "builtin" and dict[i]["texture"].split(":")[0] != "default":
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
				"}" # if adding more properties, add \n here
	
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
					if data.keys()[0].begins_with("T_"):
						if !(data.keys()[0].substr(2) in PackLoader.textureNode.TEXTURES.keys()):
							PackLoader.load_texture(data.values()[0], Globals.CUSTOMID, data.keys()[0].substr(2))
					elif data.keys()[0].begins_with("E_"):
						if !(data.keys()[0].substr(2) in PackLoader.entityNode.ENTITIES.keys()):
							PackLoader.load_entity(data[data.keys()[0]], data.keys()[0].split(":")[0].substr(2), data.keys()[0].split(":")[-1])
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
								if (Globals.CUSTOMID + ":" + ID) in PackLoader.textureNode.TEXTURES.keys():
									data[str(i)]["texdata"] = PackLoader.textureNode.get_texture(Globals.CUSTOMID + ":" + ID)
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
			block.set_material_side(cube.get_portal2_type(plane), dirs[plane])
		vmf.add_solid(block.brush)
	for entity in self.ents:
		var portal2id: String = PackLoader.get_entity_portal2_id(entity["ID"].split(":")[-1])
		if portal2id == "info_player_start":
			# warning-ignore:return_value_discarded
			VMF.Entities.Common.InfoPlayerStartEntity.new(vmf, self.get_translated_entity_position_in_vmf(entity["posx"], entity["posy"], entity["posz"]))
		elif portal2id == "light":
			# warning-ignore:return_value_discarded
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
				var tex: String = PackLoader.get_selected_texture()
				if tex == "":
					tex = Globals.TEXTUREFALLBACK
				self.add_cube(self.get_placed_cube_pos(cubeid, plane), tex)
			elif key == BUTTON_RIGHT and not drag:
				self.remove_cube(cubeid)
		
		Globals.TOOL.TEXTURE:
			if key == BUTTON_LEFT and not drag:
				pass # TODO: add context menu here
			elif key == BUTTON_RIGHT:
				var tex: String = PackLoader.get_selected_texture()
				if tex != "":
					self.cubes[cubeid].set_type(plane, tex)
		
		Globals.TOOL.PLACEENTITY:
			if key == BUTTON_RIGHT and not drag:
				var ent: String = PackLoader.get_selected_entity()
				if ent != "" and plane == Globals.PLANEID.YP:
					self.add_entity(self.get_placed_ent_pos(cubeid, plane))
		
		Globals.TOOL.CONNECTION:
			pass
		
		_:
			print("Room._on_face_selected says how?")

func _on_Select_pressed():
	self.toolSelected = Globals.TOOL.SELECT
	Globals.CLEAR_SELECTED_TOOLS()
	self.tool_select_btn.pressed = true
	self.emit_signal("shrink_sidebar")
	for ent in self.ents:
		ent["node"].set_collider_disabled(true)

func _on_VoxelBuild_pressed():
	self.toolSelected = Globals.TOOL.VOXEL
	Globals.CLEAR_SELECTED_TOOLS()
	self.tool_build_btn.pressed = true
	self.unhighlight_all()
	self.emit_signal("shrink_sidebar")
	for ent in self.ents:
		ent["node"].set_collider_disabled(true)

func _on_VoxelTextured_pressed():
	self.toolSelected = Globals.TOOL.TEXTURE
	Globals.CLEAR_SELECTED_TOOLS()
	self.tool_texture_btn.pressed = true
	self.add_button.disabled = false
	self.remove_button.disabled = false
	self.search_box.editable = true
	self.unhighlight_all()
	self.emit_signal("grow_sidebar")
	for ent in self.ents:
		ent["node"].set_collider_disabled(true)

func _on_PlaceEntity_pressed() -> void:
	self.toolSelected = Globals.TOOL.PLACEENTITY
	Globals.CLEAR_SELECTED_TOOLS()
	self.tool_placeentity_btn.pressed = true
	self.add_button.disabled = false
	self.remove_button.disabled = false
	self.search_box.editable = true
	self.unhighlight_all()
	self.emit_signal("grow_sidebar")
	for ent in self.ents:
		ent["node"].set_collider_disabled(false)

func _on_Connection_pressed() -> void:
	self.toolSelected = Globals.TOOL.CONNECTION
	Globals.CLEAR_SELECTED_TOOLS()
	self.tool_connection_btn.pressed = true
	self.add_button.disabled = true
	self.remove_button.disabled = true
	self.search_box.editable = false
	self.unhighlight_all()
	self.emit_signal("grow_sidebar")
	for ent in self.ents:
		ent["node"].set_collider_disabled(false)

func _on_RemoveTexture(id) -> void:
	for cube in self.cubes:
		for i in range(6):
			if cube.get_type(i) == id:
				cube.set_type(i, Globals.TEXTUREFALLBACK)

func _on_RemoveEntity(id) -> void:
	for ent in self.ents:
		if ent["ID"] == id:
			LogicManager.remove_logic_entity(ent["logicID"])
			ent["node"].queue_free()
