extends Popup


func set_portal2_visibility(visible: bool) -> void:
	if visible:
		$"TabContainer/Portal 2/GameDir".show()
		$"TabContainer/Portal 2/GameInfo".show()
		$"TabContainer/Portal 2/ExePath".show()
		$"TabContainer/Portal 2/VBSP".show()
		$"TabContainer/Portal 2/VVIS".show()
		$"TabContainer/Portal 2/VRAD".show()
		$"TabContainer/Portal 2/RunGame".show()
		$"TabContainer/Portal 2/TextEdit".show()
		$"TabContainer/Portal 2/Unusable".hide()
	else:
		$"TabContainer/Portal 2/GameDir".hide()
		$"TabContainer/Portal 2/GameInfo".hide()
		$"TabContainer/Portal 2/ExePath".hide()
		$"TabContainer/Portal 2/VBSP".hide()
		$"TabContainer/Portal 2/VVIS".hide()
		$"TabContainer/Portal 2/VRAD".hide()
		$"TabContainer/Portal 2/RunGame".hide()
		$"TabContainer/Portal 2/TextEdit".hide()
		$"TabContainer/Portal 2/Unusable".show()

func _on_Close_pressed() -> void:
	self.hide()
	get_parent().get_node("Properties").set_portal2_properties( \
		$"TabContainer/Portal 2/ExePath/LineEdit".text, \
		$"TabContainer/Portal 2/GameDir/LineEdit".text, \
		$"TabContainer/Portal 2/VBSP/LineEdit".text, \
		$"TabContainer/Portal 2/VVIS/LineEdit".text, \
		$"TabContainer/Portal 2/VRAD/LineEdit".text, \
		$"TabContainer/Portal 2/GameInfo/LineEdit".text, \
		$"TabContainer/Portal 2/RunGame/CenterContainer/CheckButton".pressed)
	get_parent().get_node("Properties").save()

func _on_SaveVMF_pressed() -> void:
	var filenam: String = $"TabContainer/Portal 2/GameInfo/LineEdit".text + "/" + get_parent().get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text + ".vmf"
	get_parent().get_parent().get_parent().get_node("Scene/Room").export_to_vmf(filenam)
	$"TabContainer/Portal 2/TextEdit".text += "\nAttempted to save to " + filenam

func _on_BuildRun_pressed() -> void:
	$"TabContainer/Portal 2/TextEdit".text = ""
	_on_SaveVMF_pressed()
	$"TabContainer/Portal 2/TextEdit".text += "\n\n"
	var filenam: String = $"TabContainer/Portal 2/GameInfo/LineEdit".text + "/" + get_parent().get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text + ".vmf"
	var levelname: String = get_parent().get_parent().get_parent().get_node("Menu/Control/TopBar/CenterMenu/LevelName").text
	var output = []
	# warning-ignore:return_value_discarded
	OS.execute($"TabContainer/Portal 2/VBSP/LineEdit".text, ["-game", $"TabContainer/Portal 2/GameDir/LineEdit".text, filenam], true, output, true)
	$"TabContainer/Portal 2/TextEdit".text += output[0]
	output = []
	# warning-ignore:return_value_discarded
	OS.execute($"TabContainer/Portal 2/VVIS/LineEdit".text, ["-game", $"TabContainer/Portal 2/GameDir/LineEdit".text, filenam], true, output, true)
	$"TabContainer/Portal 2/TextEdit".text += output[0]
	output = []
	# warning-ignore:return_value_discarded
	OS.execute($"TabContainer/Portal 2/VRAD/LineEdit".text, ["-both", "-final", "-textureshadows", "-StaticPropLighting", "-StaticPropPolys", "-game", $"TabContainer/Portal 2/GameDir/LineEdit".text, filenam], true, output, true)
	$"TabContainer/Portal 2/TextEdit".text += output[0]
	if $"TabContainer/Portal 2/RunGame/CenterContainer/CheckButton".pressed:
		# warning-ignore:return_value_discarded
		OS.execute($"TabContainer/Portal 2/ExePath/LineEdit".text, ["-dev", "-game", $"TabContainer/Portal 2/GameDir/LineEdit".text, "+map", levelname + ".bsp", "+sv_lan", "1"], false)

func _on_TabContainer_tab_changed(tab: int) -> void:
	match tab:
		0:
			$Panel/HBoxContainer/BuildRun.hide()
			$Panel/HBoxContainer/SaveVMF.hide()
		1:
			if OS.get_name() == "Windows":
				$Panel/HBoxContainer/BuildRun.show()
				$Panel/HBoxContainer/SaveVMF.show()
