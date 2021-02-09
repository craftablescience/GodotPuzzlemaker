extends MenuButton


var popup: PopupMenu
var levelName: LineEdit

signal save_level


func _ready() -> void:
	self.popup = get_popup()
	self.popup.add_item("New")
	self.popup.add_item("Open...")
	self.popup.add_item("Save")
	#self.popup.add_item("Export...")
	if (OS.get_name() != "HTML5"):
		self.popup.add_item("Exit")
	# warning-ignore:return_value_discarded
	self.popup.connect("id_pressed", self, "_on_item_pressed")
	
	self.levelName = get_parent().get_parent().get_parent().get_node("TopBar/CenterMenu/LevelName")
	
	# warning-ignore:return_value_discarded
	self.connect("save_level", get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Scene/Room"), "save")

func _on_item_pressed(id : int) -> void:
	match id:
		0:
			if self.levelName.text != "":
				self.emit_signal("save_level", self.levelName.text)
			get_parent().get_parent().get_parent().get_node("ConfirmNewLevel").popup_centered()
		1:
			get_parent().get_parent().get_parent().get_node("FileSelect").popup()
		2:
			if self.levelName.text != "":
				self.emit_signal("save_level", self.levelName.text)
			else:
				get_parent().get_parent().get_parent().get_node("MissingLevelNameDialog").popup_centered()
		3:
			if self.levelName.text != "":
				self.emit_signal("save_level", self.levelName.text)
			get_parent().get_parent().get_parent().get_node("QuitRequest").popup_centered()
		_:
			print("File says how?")
