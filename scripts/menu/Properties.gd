extends Popup


var musictgl: bool
var soundtgl: bool
var mobilebtn: bool
var windowSize: int


func _ready() -> void:
	if OS.get_name() == "HTML5":
		get_node("TabContainer/General/Music").hide()

func __init() -> void:
	self.musictgl = get_node("TabContainer/General/Music/Music").pressed
	self.soundtgl = get_node("TabContainer/General/Sound/Sound").pressed
	self.mobilebtn = get_node("TabContainer/General/Mobile/Mobile").pressed
	self.windowSize = get_node("TabContainer/General/WindowSize/HBoxContainer/WindowSize").get_selected_id()
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
		0:
			OS.window_borderless = false
			OS.window_fullscreen = false
		1:
			OS.window_fullscreen = true
			OS.window_borderless = true
			OS.window_fullscreen = false
		2:
			OS.window_fullscreen = true


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
	windowSize = index
	self.update()
