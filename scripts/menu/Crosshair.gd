extends Sprite


func _ready():
	self.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	self.hide()

func _on_editor_camera_active():
	self.show()

func _on_editor_camera_inactive():
	self.hide()
