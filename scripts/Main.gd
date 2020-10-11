extends Spatial


func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if get_node("Menu/Control/TopBar/CenterMenu/LevelName").text != "":
			get_node("Menu/Control/TopBar/LeftMenu/File").emit_signal("save_level", get_node("Menu/Control/TopBar/CenterMenu/LevelName").text)
		get_node("Menu/Control/QuitRequest").popup_centered()
