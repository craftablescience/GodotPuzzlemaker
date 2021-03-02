extends Popup


func set_portal2_visibility(visible: bool) -> void:
	if visible:
		$"TabContainer/Portal 2".show()
	else:
		$"TabContainer/Portal 2".hide()


func _on_Close_pressed() -> void:
	self.hide()
	get_parent().get_node("Properties").set_portal2_properties( \
		$"TabContainer/Portal 2/ExePath/LineEdit".text, \
		$"TabContainer/Portal 2/VBSP/LineEdit".text, \
		$"TabContainer/Portal 2/VVIS/LineEdit".text, \
		$"TabContainer/Portal 2/VRAD/LineEdit".text, \
		$"TabContainer/Portal 2/RunGame/CenterContainer/CheckButton".pressed, \
		$"TabContainer/Portal 2/GameInfo/LineEdit".text)
	get_parent().get_node("Properties").save()

func _on_SaveVMF_pressed() -> void:
	var filenam: String = "user://" + get_parent().get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text + ".vmf"
	get_parent().get_parent().get_parent().get_node("Scene/Room").export_to_vmf(filenam)
