extends Popup


var musictgl: bool
var soundtgl: bool
var mobilebtn: bool
var windowSize: int
var keyboardType: int
var mouseSensitivity: float
var cameraSpeed: float
var p2vmfexport: bool

var p2_exe: String
var p2_gamedir: String
var p2_gameinfo: String
var p2_vvis: String
var p2_vbsp: String
var p2_vrad: String
var p2_runonbuild: bool


enum WINDOW_TYPE {
	WINDOWED,
	BORDERLESS,
	FULLSCREEN
}

enum KEYBOARD_TYPE {
	QWERTY,
	AZERTY
}


func __init() -> void:
	self.musictgl = get_node("TabContainer/General/Music/Music").pressed
	self.soundtgl = get_node("TabContainer/General/Sound/Sound").pressed
	self.mobilebtn = get_node("TabContainer/General/Mobile/Mobile").pressed
	get_node("TabContainer/General/Mobile").hide()
	self.windowSize = get_node("TabContainer/General/WindowSize/HBoxContainer/WindowSize").get_selected_id()
	self.keyboardType = get_node("TabContainer/General/KeyboardLayout/HBoxContainer/KeyboardLayout").get_selected_id()
	self.mouseSensitivity = get_node("TabContainer/General/MouseSensitivity/MouseSensitivity").get_value()
	self.cameraSpeed = get_node("TabContainer/General/CameraSpeed/CameraSpeed").get_value()
	if OS.get_name() == "Windows":
		self.p2vmfexport = get_node("TabContainer/Experimental/P2VMFExport/P2VMFExport").pressed
	else:
		self.p2vmfexport = false
	
	self.p2_exe = get_parent().get_node("ExportDialog/TabContainer/Portal 2/ExePath/LineEdit").text
	self.p2_gamedir = get_parent().get_node("ExportDialog/TabContainer/Portal 2/GameDir/LineEdit").text
	self.p2_gameinfo = get_parent().get_node("ExportDialog/TabContainer/Portal 2/GameInfo/LineEdit").text
	self.p2_vvis = get_parent().get_node("ExportDialog/TabContainer/Portal 2/VVIS/LineEdit").text
	self.p2_vbsp = get_parent().get_node("ExportDialog/TabContainer/Portal 2/VBSP/LineEdit").text
	self.p2_vrad = get_parent().get_node("ExportDialog/TabContainer/Portal 2/VRAD/LineEdit").text
	self.p2_runonbuild = get_parent().get_node("ExportDialog/TabContainer/Portal 2/RunGame/CenterContainer/CheckButton").pressed
	
	self.update()

func save() -> void:
	var fil: File = File.new()
	# warning-ignore:return_value_discarded
	fil.open("user://settings.cfg", fil.WRITE)
	var out: String = ""
	out += "{"  + "\"VERSION\":"    + str(Globals.FILESETTINGSFORMAT)                                          + "}"
	out += "\n" + "{\"THEME\":"     + str(get_parent().get_node("TopBar/LeftMenu/Edit").get_theme_selection()) + "}"
	out += "\n" + "{\"mobilebtn\":" + str(self.mobilebtn).to_lower()                                           + "}"
	out += "\n" + "{\"musictgl\":"  + str(self.musictgl).to_lower()                                            + "}"
	out += "\n" + "{\"soundtgl\":"  + str(self.soundtgl).to_lower()                                            + "}"
	out += "\n" + "{\"windowSize\":" + str(self.windowSize)                                                    + "}"
	out += "\n" + "{\"keyboardType\":" + str(self.keyboardType)                                                + "}"
	out += "\n" + "{\"mouseSensitivity\":" + str(self.mouseSensitivity)                                        + "}"
	out += "\n" + "{\"cameraSpeed\":" + str(self.cameraSpeed)                                                  + "}"
	out += "\n" + "{\"p2vmfexport\":" + str(self.p2vmfexport).to_lower()                                       + "}"
	
	out += "\n" + "{\"p2gameinfo\":" + "\"" + str(self.p2_gameinfo) + "\""                                     + "}"
	out += "\n" + "{\"p2gamedir\":" + "\"" + str(self.p2_gamedir) + "\""                                       + "}"
	out += "\n" + "{\"p2exe\":" + "\"" + str(self.p2_exe) + "\""                                               + "}"
	out += "\n" + "{\"p2vvis\":" + "\"" + str(self.p2_vvis) + "\""                                             + "}"
	out += "\n" + "{\"p2vbsp\":" + "\"" + str(self.p2_vbsp) + "\""                                             + "}"
	out += "\n" + "{\"p2vrad\":" + "\"" + str(self.p2_vrad) + "\""                                             + "}"
	out += "\n" + "{\"p2runonbuild\":" + str(self.p2_runonbuild).to_lower()                                    + "}"
	
	fil.store_string(out)
	fil.close()

func update() -> void:
	# Music
	var bgMusic: AudioStreamPlayer = get_parent().get_parent().get_parent().get_node("BackgroundMusic")
	if self.musictgl:
		if !bgMusic.playing:
			bgMusic.play()
	else:
		bgMusic.stop()
	# Sound
	for sound in get_tree().get_nodes_in_group("SFX"):
		sound.set_disabled(!self.soundtgl)
	# Mobile
	if self.mobilebtn:
		get_parent().get_node("TopBar/CenterMenu/Mobile").show()
	else:
		get_parent().get_node("TopBar/CenterMenu/Mobile").hide()
	
	match windowSize:
		WINDOW_TYPE.WINDOWED:
			OS.window_borderless = false
			OS.window_fullscreen = false
		WINDOW_TYPE.BORDERLESS:
			OS.window_fullscreen = true
			OS.window_borderless = true
			OS.window_fullscreen = false
		WINDOW_TYPE.FULLSCREEN:
			OS.window_fullscreen = true
	
	match keyboardType:
		KEYBOARD_TYPE.QWERTY:
			InputMap.load_from_globals()
		KEYBOARD_TYPE.AZERTY:
			var KEYQ: InputEventKey = InputEventKey.new()
			KEYQ.set_scancode(KEY_A)
			var KEYW: InputEventKey = InputEventKey.new()
			KEYW.set_scancode(KEY_Z)
			var KEYA: InputEventKey = InputEventKey.new()
			KEYA.set_scancode(KEY_Q)
			InputMap.action_erase_events("editor_camera_toggle")
			InputMap.action_add_event("editor_camera_toggle", KEYQ)
			InputMap.action_erase_events("editor_camera_forward")
			InputMap.action_add_event("editor_camera_forward", KEYW)
			InputMap.action_erase_events("editor_camera_left")
			InputMap.action_add_event("editor_camera_left", KEYA)
	
	Globals.MOUSE_SENSITIVITY = self.mouseSensitivity / 1000.0
	Globals.MOVEMENT_SENSITIVITY = self.cameraSpeed / 20.0
	
	if OS.get_name() == "Windows":
		get_parent().get_node("ExportDialog").set_portal2_visibility(p2vmfexport)
	else:
		get_parent().get_node("ExportDialog").set_portal2_visibility(false)

func set_portal2_properties(p2exe: String, gamedir: String, vbsp: String, vvis: String, vrad: String, gameinfo: String, runonbuild: bool) -> void:
	self.p2_exe = p2exe
	self.p2_gamedir = gamedir
	self.p2_vbsp = vbsp
	self.p2_vrad = vrad
	self.p2_vvis = vvis
	self.p2_runonbuild = runonbuild
	self.p2_gameinfo = gameinfo

func get_keyboard_type() -> int:
	return self.keyboardType

func _on_Music_toggled(button_pressed: bool) -> void:
	self.musictgl = button_pressed
	self.update()

func _on_Sound_toggled(button_pressed: bool) -> void:
	self.soundtgl = button_pressed
	self.update()

func _on_Mobile_toggled(button_pressed: bool) -> void:
	self.mobilebtn = button_pressed
	self.update()

func _on_Close_pressed() -> void:
	self.hide()
	self.save()

func _on_WindowSize_item_selected(index: int) -> void:
	self.windowSize = index
	self.update()

func _on_KeyboardLayout_item_selected(index: int) -> void:
	self.keyboardType = index
	self.update()

func _on_MouseSensitivity_value_changed(value: float) -> void:
	if value < 1:
		value = 1
	self.mouseSensitivity = value
	self.update()

func _on_CameraSpeed_value_changed(value: float) -> void:
	if value < 1:
		value = 1
	self.cameraSpeed = value
	self.update()

func _on_P2VMFExport_toggled(button_pressed: bool) -> void:
	self.p2vmfexport = button_pressed
	self.update()
