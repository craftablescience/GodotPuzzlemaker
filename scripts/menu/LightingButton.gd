extends Button


func _on_toggled(button_pressed: bool) -> void:
	if button_pressed:
		get_parent().get_node("LightPanel")._on_grow()
	else:
		get_parent().get_node("LightPanel")._on_shrink()
