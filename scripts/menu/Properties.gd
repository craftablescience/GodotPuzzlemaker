extends Popup


var musictgl: bool
var soundtgl: bool
var mobilebtn: bool
var windowSize: int
var keyboardType: int


enum WINDOW_TYPE {
	WINDOWED,
	BORDERLESS,
	FULLSCREEN
}

enum KEYBOARD_TYPE {
	QWERTY,
	AZERTY
}


func _ready() -> void:
	if OS.get_name() == "HTML5":
		get_node("TabContainer/General/Music").hide()

func __init() -> void:
	self.musictgl = get_node("TabContainer/General/Music/Music").pressed
	self.soundtgl = get_node("TabContainer/General/Sound/Sound").pressed
	self.mobilebtn = get_node("TabContainer/General/Mobile/Mobile").pressed
	self.windowSize = get_node("TabContainer/General/WindowSize/HBoxContainer/WindowSize").get_selected_id()
	self.keyboardType = get_node("TabContainer/General/KeyboardLayout/HBoxContainer/KeyboardLayout").get_selected_id()
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
