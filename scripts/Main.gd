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
		# warning-ignore:return_value_discarded
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
			var musicSet: bool = false
			var soundSet: bool = false
			var mobileSet: bool = false
			var windowSize: bool = false
			var keyboardType: bool = false
			for line in ary:
				if "musictgl" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Music/Music").pressed = bool(line["musictgl"])
					musicSet = true
				if "soundtgl" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Sound/Sound").pressed = bool(line["soundtgl"])
					soundSet = true
				if "mobilebtn" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/Mobile/Mobile").pressed = bool(line["mobilebtn"])
					mobileSet = true
				if "windowSize" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/WindowSize/HBoxContainer/WindowSize").select(int(line["windowSize"]))
					windowSize = true
				if "keyboardType" in line.keys():
					get_node("Menu/Control/Properties/TabContainer/General/KeyboardLayout/HBoxContainer/KeyboardLayout").select(int(line["keyboardType"]))
					keyboardType = true
			if !musicSet:
				get_node("Menu/Control/Properties/TabContainer/General/Music/Music").pressed = true
			if !soundSet:
				get_node("Menu/Control/Properties/TabContainer/General/Sound/Sound").pressed = true
			if !mobileSet:
				get_node("Menu/Control/Properties/TabContainer/General/Sound/Sound").pressed = false
			if !windowSize:
				get_node("Menu/Control/Properties/TabContainer/General/WindowSize/HBoxContainer/WindowSize").select(0)
			if !keyboardType:
				get_node("Menu/Control/Properties/TabContainer/General/KeyboardLayout/HBoxContainer/KeyboardLayout").select(0)
	
	if OS.get_name() == "HTML5":
		get_node("Menu/Control/Properties/TabContainer/General/WindowSize/HBoxContainer/WindowSize").select(0)
		get_node("Menu/Control/Properties/TabContainer/General/WindowSize").hide()
	
	get_node("Menu/Control/Properties").__init()
	get_node("Menu/Control/LightPanel").__init(false, true, 0, 0, 100, 100)

func _notification(notification):
	if notification == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if get_node("Menu/Control/TopBar/CenterMenu/LevelName").text != "":
			get_node("Menu/Control/TopBar/LeftMenu/File").emit_signal("save_level", get_node("Menu/Control/TopBar/CenterMenu/LevelName").text)
		get_node("Menu/Control/QuitRequest").popup_centered()
