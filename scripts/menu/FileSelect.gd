extends FileDialog


signal load_save


func _ready() -> void:
	# warning-ignore:return_value_discarded
	self.connect("load_save", get_parent().get_parent().get_parent().get_node("Scene/Room"), "load_save")

func _on_file_selected(path: String) -> void:
	self.emit_signal("load_save", path)

func _on_about_to_show():
	self.invalidate()
