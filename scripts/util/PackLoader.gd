extends Node


const gdunzip_file = preload("res://addons/gdunzip/gdunzip.gd")
var gdunzip
var textureNode
var entityNode


func _ready() -> void:
	# warning-ignore:return_value_discarded
	get_tree().connect("files_dropped", self, "_get_dropped_files")
	
	gdunzip = gdunzip_file.new()
	self.load_resource_pack("res://asset_pack/", false)

func set_texture_list(node: Node) -> void:
	self.textureNode = node

func set_entity_list(node: Node) -> void:
	self.entityNode = node

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

func load_resource_pack(path: String, zip: bool = true) -> void:
	"""todo: add warning on import saying which textures do not have portal 2 textures if portal 2 export enabled"""
	pass

func load_texture(data: String, ID: String) -> void:
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
	#i.resize(64, 64, Image.INTERPOLATE_LANCZOS)
	img.create_from_image(i, 1)
	if !(Globals.CUSTOMID + ":" + ID in self.textureNode.TEXTURES):
		self.textureNode.add_item(Globals.CUSTOMID,
		ID.split("/")[-1].split(".")[0], ID,
		img)

func load_entity(data: String, category: String, ID: String) -> void:
	var efile: File = File.new()
	# warning-ignore:return_value_discarded
	efile.open("user://.cache/" + ID, efile.WRITE)
	efile.store_buffer(Marshalls.base64_to_raw(data))
	efile.close()
	self.entityNode.add_item(category, ID.split(".")[0], ID, load("user://.cache/" + ID))
