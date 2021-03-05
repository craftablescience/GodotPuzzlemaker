extends MenuButton


var popup: PopupMenu
var levelName: LineEdit

signal save_level


func _ready() -> void:
	var new_shortcut = ShortCut.new()
	new_shortcut.set_shortcut(InputMap.get_action_list("ui_new_level")[0])
	var open_shortcut = ShortCut.new()
	open_shortcut.set_shortcut(InputMap.get_action_list("ui_open_level")[0])
	var save_shortcut = ShortCut.new()
	save_shortcut.set_shortcut(InputMap.get_action_list("ui_save_level")[0])
	var export_shortcut = ShortCut.new()
	export_shortcut.set_shortcut(InputMap.get_action_list("ui_export")[0])
	var exit_shortcut = ShortCut.new()
	exit_shortcut.set_shortcut(InputMap.get_action_list("ui_exit")[0])
	
	self.popup = get_popup()
	self.popup.add_item("New")
	self.popup.set_item_shortcut(0, new_shortcut)
	self.popup.add_item("Open...")
	self.popup.set_item_shortcut(1, open_shortcut)
	self.popup.add_item("Save")
	self.popup.set_item_shortcut(2, save_shortcut)
	self.popup.add_item("Export...")
	self.popup.set_item_shortcut(3, export_shortcut)
	if (OS.get_name() != "HTML5"):
		self.popup.add_item("Exit")
		self.popup.set_item_shortcut(4, exit_shortcut)
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
			get_parent().get_parent().get_parent().get_node("ExportDialog").popup_centered()
		4:
			if self.levelName.text != "":
				self.emit_signal("save_level", self.levelName.text)
			get_parent().get_parent().get_parent().get_node("QuitRequest").popup_centered()
		_:
			assert(false, "File says how?")
