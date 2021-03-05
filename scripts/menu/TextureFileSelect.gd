extends FileDialog


func _on_about_to_show() -> void:
	self.invalidate()

func _on_file_selected(path: String) -> void:
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		get_parent().get_node("TextureError").popup_centered()
	else:
		var cache: Directory = Directory.new()
		if !cache.dir_exists("user://.cache"):
			# warning-ignore:return_value_discarded
			cache.make_dir("user://.cache")
		# warning-ignore:return_value_discarded
		cache.open("user://.cache")
		var copy: File = File.new()
		var original: File = File.new()
		# warning-ignore:return_value_discarded
		copy.open("user://.cache/" + path.split("/")[-1], copy.WRITE)
		# warning-ignore:return_value_discarded
		original.open(path, original.READ)
		copy.store_buffer(original.get_buffer(original.get_len()))
		copy.close()
		original.close()
		#image.resize(64, 64, Image.INTERPOLATE_LANCZOS)
		var texture = ImageTexture.new()
		texture.create_from_image(image, 1)
		var ID: String = path.split("/")[-1]
		get_parent().get_node("ContextPanel/TabContainer/Textures/Tree").add_item(Globals.CUSTOMID, ID, ID, texture)
