extends FileDialog


func _on_about_to_show() -> void:
	self.invalidate()

func _on_file_selected(path: String) -> void:
	if path.ends_with("zip"):
		PackLoader.load_resource_pack(path)
		return
	var scn: PackedScene = load(path)
	var ID: String = path.split("/")[-1]
	var copy: File = File.new()
	var original: File = File.new()
	# warning-ignore:return_value_discarded
	copy.open("user://.cache/" + path.split("/")[-1], copy.WRITE)
	# warning-ignore:return_value_discarded
	original.open(path, original.READ)
	copy.store_buffer(original.get_buffer(original.get_len()))
	copy.close()
	original.close()
	get_parent().get_node("ContextPanel/TabContainer/Entities/Tree").add_item(Globals.CUSTOMID, ID.split(".")[0], ID, scn)
