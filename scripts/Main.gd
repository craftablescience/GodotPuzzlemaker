extends Spatial


func _ready() -> void:
	# Touchscreen controls
	if OS.get_name() == "HTML5" or OS.get_name() == "Android" or OS.get_name() == "iOS":
		get_node("Menu/Control/TopBar/CenterMenu/Mobile").show()
	else:
		get_node("Menu/Control/TopBar/CenterMenu/Mobile").hide()
	
	var settings: File = File.new()
	var ary: Array = []
	if settings.file_exists("user://settings.cfg"):
		settings.open("user://settings.cfg", settings.READ)
		for line in settings.get_as_text().split("\n"):
			ary.append(parse_json(line))
		settings.close()
		if ary[0]["VERSION"] != Globals.FILESETTINGSFORMAT:
			get_node("Menu/Control/LoadSettingsError").popup_centered()
		else:
			ary.remove(0)
			get_node("Menu/Control/TopBar/LeftMenu/Edit").__init(int(ary[0]["THEME"]))
			ary.remove(0)
			for line in ary:
				if "musictgl" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Music/Music").pressed = bool(line["musictgl"])
				elif "soundtgl" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Sound/Sound").pressed = bool(line["soundtgl"])
				elif "mobilebtn" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Mobile/Mobile").pressed = bool(line["mobilebtn"])
	get_node("Menu/Control/Properties").__init()

func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if get_node("Menu/Control/TopBar/CenterMenu/LevelName").text != "":
			get_node("Menu/Control/TopBar/LeftMenu/File").emit_signal("save_level", get_node("Menu/Control/TopBar/CenterMenu/LevelName").text)
		get_node("Menu/Control/QuitRequest").popup_centered()
