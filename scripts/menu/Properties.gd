extends Popup


var musictgl: bool
var soundtgl: bool


func _ready() -> void:
	if OS.get_name() == "HTML5":
		get_node("TabContainer/General/Music").hide()

func __init() -> void:
	self.musictgl = get_node("TabContainer/General/Music/Music").pressed
	self.soundtgl = get_node("TabContainer/General/Sound/Sound").pressed
	self.update()

func save() -> void:
	var fil: File = File.new()
	fil.open("user://settings.cfg", fil.WRITE)
	var out: String = ""
	out += "{"  + "\"VERSION\":"   + str(Globals.FILESETTINGSFORMAT) + "}"
	out += "\n" + "{\"musictgl\":" + str(musictgl).to_lower()        + "}"
	out += "\n" + "{\"soundtgl\":" + str(soundtgl).to_lower()        + "}"
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

func _on_Music_toggled(button_pressed: bool) -> void:
	self.musictgl = button_pressed
	self.update()

func _on_Sound_toggled(button_pressed: bool) -> void:
	self.soundtgl = button_pressed
	self.update()

func _on_Close_pressed() -> void:
	self.hide()
	self.save()
