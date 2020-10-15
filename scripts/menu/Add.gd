extends Button


func _ready() -> void:
	if OS.get_name() == "HTML5":
		self.disabled = true
	else:
		self.disabled = false

func _on_pressed() -> void:
	if get_parent().get_parent().get_node("TabContainer/Entities").visible:
		get_parent().get_parent().get_parent().get_node("EntityFileSelect").popup_centered()
	elif get_parent().get_parent().get_node("TabContainer/Textures").visible:
		get_parent().get_parent().get_parent().get_node("TextureFileSelect").popup_centered()
