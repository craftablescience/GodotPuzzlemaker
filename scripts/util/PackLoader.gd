extends Node


const gdunzip_file = preload("res://addons/gdunzip/gdunzip.gd")
onready var gdunzip = gdunzip_file.new()
var textureNode: Tree
var entityNode: Tree
var errorPopup: AcceptDialog
var exportDialog: Popup
var portal2entities: Dictionary


func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().connect("files_dropped", self, "_get_dropped_files")

func set_texture_list(node: Tree) -> void:
	self.textureNode = node

func set_entity_list(node: Tree) -> void:
	self.entityNode = node

func set_error_dialog(node: AcceptDialog) -> void:
	self.errorPopup = node

func set_export_dialog(node: Popup) -> void:
	self.exportDialog = node

func _get_dropped_files(filepaths: PoolStringArray, _screen: int) -> void:
	for path in filepaths:
		path = path.replace("\\", "/")
		if path.ends_with("png") or path.ends_with("jpg"):
			var loadedFile: File = File.new()
			# warning-ignore:return_value_discarded
			loadedFile.open(path, File.READ)
			var cache: File = File.new()
			var img: ImageTexture = ImageTexture.new()
			var i: Image = Image.new()
			var buffer: PoolByteArray = loadedFile.get_buffer(loadedFile.get_len())
			loadedFile.close()
			if path.ends_with("png"):
				# warning-ignore:return_value_discarded
				i.load_png_from_buffer(buffer)
			if path.ends_with("jpg"):
				# warning-ignore:return_value_discarded
				i.load_jpg_from_buffer(buffer)
			# warning-ignore:return_value_discarded
			cache.open("user://.cache/" + path.split("/")[-1], cache.WRITE)
			cache.store_buffer(buffer)
			cache.close()
			img.create_from_image(i, 1)
			if !(Globals.CUSTOMID + ":" + path.split("/")[-1] in self.textureNode.TEXTURES):
				self.textureNode.add_item(Globals.CUSTOMID,
				path.split("/")[-1].split(".")[0], path.split("/")[-1],
				img)
		elif path.ends_with("scn"):
			var efile: File = File.new()
			var input: File = File.new()
			# warning-ignore:return_value_discarded
			input.open(path, File.READ)
			# warning-ignore:return_value_discarded
			efile.open("user://.cache/" + path.split("/")[-1], efile.WRITE)
			efile.store_buffer(input.get_buffer(input.get_len()))
			efile.close()
			input.close()
			self.entityNode.add_item(Globals.CUSTOMID, path.split("/")[-1].split(".")[0], path.split("/")[-1], load("user://.cache/" + path.split("/")[-1]))
		elif path.ends_with("zip"):
			load_resource_pack(path)

func load_resource_pack(path: String) -> void:
	var copy: File = File.new()
	var original: File = File.new()
	# warning-ignore:return_value_discarded
	copy.open("user://.cache/" + path.split("/")[-1], File.WRITE)
	# warning-ignore:return_value_discarded
	original.open(path, File.READ)
	copy.store_buffer(original.get_buffer(original.get_len()))
	copy.close()
	original.close()
	path = "user://.cache/" + path.split("/")[-1]
	gdunzip.load(path)
	var manifest_fil = gdunzip.uncompress("pack_manifest.json")
	if !manifest_fil:
		self.errorPopup.dialog_text = "Error loading custom resource pack: Missing pack manifest"
		self.errorPopup.popup_centered()
		return
	var manifest = JSON.parse(manifest_fil.get_string_from_utf8())
	if manifest.error == OK:
		var category: Dictionary = manifest.result["category"]
		var textures: Array      = manifest.result["textures"]
		var entities: Array      = manifest.result["entities"]
		var categoryID: String = category["id"]
		var texcount: int = 0
		var entcount: int = 0
		if !textures.empty():
			self.textureNode.add_category(category["name"], categoryID)
			var cache: File = File.new()
			for texdict in textures:
				texcount += 1
				var filepath: String = texdict["path"]
				var image: ImageTexture = ImageTexture.new()
				var imgdata = gdunzip.uncompress("textures/" + filepath)
				var i: Image = Image.new()
				if filepath.ends_with("png"):
					# warning-ignore:return_value_discarded
					i.load_png_from_buffer(imgdata)
				elif filepath.ends_with("jpg"):
					# warning-ignore:return_value_discarded
					i.load_jpg_from_buffer(imgdata)
				image.create_from_image(i, 1)
				# warning-ignore:return_value_discarded
				cache.open("user://.cache/" + texdict["path"].split("/")[-1], cache.WRITE)
				cache.store_buffer(imgdata)
				cache.close()
				self.add_texture(image, texdict["name"], categoryID, texdict["id"])
				if texdict.has("portal2_path"):
					var p2: Dictionary = texdict["portal2_path"]
					if p2.has("builtin"):
						textureNode.TEXTURES[categoryID + ":" + texdict["id"]]["portal2path"] = p2["builtin"]
					elif p2.has("vtf") or p2.has("vmt"):
						textureNode.TEXTURES[categoryID + ":" + texdict["id"]]["portal2path"] = "gpz/" + categoryID + "_" + texdict["id"]
						Globals.SAVE_DATA(gdunzip.uncompress(p2["vtf"]), "user://.cache/" + p2["vtf"].split("/")[-1])
						Globals.SAVE_DATA(gdunzip.uncompress(p2["vmt"]), "user://.cache/" + p2["vmt"].split("/")[-1])
						exportDialog.TEXTURES.append({"file": "user://.cache/" + p2["vtf"].split("/")[-1], "name": "materials/gpz/" + p2["vtf"].split("/")[-1], "short": p2["vtf"].split("/")[-1]})
						exportDialog.TEXTURES.append({"file": "user://.cache/" + p2["vmt"].split("/")[-1], "name": "materials/gpz/" + p2["vmt"].split("/")[-1], "short": p2["vmt"].split("/")[-1]})
		if !entities.empty():
			self.entityNode.add_category(category["name"], categoryID)
			for entdict in entities:
				entcount += 1
				var filepath: String = entdict["path"]
				var scndata = gdunzip.uncompress("entities/" + filepath)
				var cpy: File = File.new()
				# warning-ignore:return_value_discarded
				cpy.open("user://.cache/" + filepath, copy.WRITE)
				cpy.store_buffer(scndata)
				cpy.close()
				entityNode.add_item(categoryID, entdict["name"], entdict["id"], load("user://.cache/" + filepath))
				if entdict.has("portal2_equivalent"):
					portal2entities[entdict["id"]] = entdict["portal2_equivalent"]
		self.errorPopup.dialog_text = "Loaded resource pack with " + str(texcount) + " textures and " + str(entcount) + " entities."
		self.errorPopup.popup_centered()
	else:
		self.errorPopup.dialog_text = "Error loading resource pack: Malformed JSON"
		self.errorPopup.popup_centered()
	var d = Directory.new()
	d.remove(path)

func load_default_resource_pack(path: String) -> void:
	var pmf: File = File.new()
	# warning-ignore:return_value_discarded
	pmf.open("res://editor_assets/pack_manifest.json", File.READ)
	var manifest = JSON.parse(pmf.get_as_text())
	pmf.close()
	if manifest.error == OK:
		var category: Dictionary = manifest.result["category"]
		var textures: Array      = manifest.result["textures"]
		var entities: Array      = manifest.result["entities"]
		var categoryID: String = category["id"]
		if !textures.empty():
			self.textureNode.add_category(category["name"], categoryID)
			for texdict in textures:
				var filepath: String = texdict["path"]
				var image: ImageTexture = ImageTexture.new()
				var i: Image = load(path + "textures/" + filepath)
				image.create_from_image(i, 1)
				self.add_texture(image, texdict["name"], categoryID, texdict["id"])
				if texdict.has("portal2_path"):
					var p2: Dictionary = texdict["portal2_path"]
					if p2.has("builtin"):
						textureNode.TEXTURES[categoryID + ":" + texdict["id"]]["portal2path"] = p2["builtin"]
					elif p2.has("vtf") or p2.has("vmt"):
						textureNode.TEXTURES[categoryID + ":" + texdict["id"]]["portal2path"] = "gpz/" + categoryID + "_" + texdict["id"]
						Globals.COPY_FILE(path + "textures/" + p2["vtf"], "user://.cache/" + p2["vtf"].split("/")[-1])
						Globals.COPY_FILE(path + "textures/" + p2["vmt"], "user://.cache/" + p2["vmt"].split("/")[-1])
						exportDialog.TEXTURES.append({"file": "user://.cache/" + p2["vtf"].split("/")[-1], "name": "materials/gpz/" + p2["vtf"].split("/")[-1], "short": p2["vtf"].split("/")[-1]})
						exportDialog.TEXTURES.append({"file": "user://.cache/" + p2["vmt"].split("/")[-1], "name": "materials/gpz/" + p2["vmt"].split("/")[-1], "short": p2["vmt"].split("/")[-1]})
		if !entities.empty():
			self.entityNode.add_category(category["name"], categoryID)
			for entdict in entities:
				entityNode.add_item(categoryID, entdict["name"], entdict["id"], load(path + "entities/" + entdict["path"]))
				if entdict.has("portal2_equivalent"):
					portal2entities[entdict["id"]] = entdict["portal2_equivalent"]

func add_texture(image: ImageTexture, namae: String, category: String, ID: String) -> void:
	if !(category + ":" + ID in self.textureNode.TEXTURES):
		self.textureNode.add_item(category, namae, ID, image)

func add_texture_category(namae: String, category: String) -> void:
	self.textureNode.add_category(namae, category)

func add_entity(namae: String, category: String, ID: String, ent: PackedScene) -> void:
	if !(category + ":" + ID in self.entityNode.ENTITIES):
		self.entityNode.add_item(category, namae, ID, ent)

func add_entity_category(namae: String, category: String) -> void:
	self.entityNode.add_category(namae, category)

func load_texture(data: String, category: String, ID: String) -> void:
	var cache: File = File.new()
	var img: ImageTexture = ImageTexture.new()
	var i: Image = Image.new()
	if ID.split(".")[-1] == "jpg":
		# warning-ignore:return_value_discarded
		i.load_jpg_from_buffer(Marshalls.base64_to_raw(data))
	elif ID.split(".")[-1] == "png":
		# warning-ignore:return_value_discarded
		i.load_png_from_buffer(Marshalls.base64_to_raw(data))
	# warning-ignore:return_value_discarded
	cache.open("user://.cache/" + ID, cache.WRITE)
	cache.store_buffer(Marshalls.base64_to_raw(data))
	cache.close()
	img.create_from_image(i, 1)
	if !(category + ":" + ID in self.textureNode.TEXTURES):
		self.textureNode.add_item(category,
		ID.split("/")[-1].split(".")[0], ID,
		img)

func load_entity(data: String, category: String, ID: String) -> void:
	var efile: File = File.new()
	# warning-ignore:return_value_discarded
	efile.open("user://.cache/" + ID, efile.WRITE)
	efile.store_buffer(Marshalls.base64_to_raw(data))
	efile.close()
	self.entityNode.add_item(category, ID.split(".")[0], ID, load("user://.cache/" + ID))

func get_selected_texture() -> String:
	return textureNode.get_selected_texture()

func get_selected_entity() -> String:
	return entityNode.get_selected_entity()

func get_portal2_texture_from_id(texture: String) -> String:
	if "portal2path" in self.textureNode.TEXTURES[texture].keys():
		return self.textureNode.TEXTURES[texture]["portal2path"]
	return "gpz/default_white"

func get_entity_portal2_id(id: String) -> String:
	if portal2entities.has(id):
		return portal2entities[id]
	else:
		return ""
