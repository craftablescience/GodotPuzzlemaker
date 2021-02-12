extends MenuButton


var popup: PopupMenu
var themeSubMenu: PopupMenu
var themeID: int
#var advancedSubMenu: PopupMenu


func _ready() -> void:
	var properties_shortcut = ShortCut.new()
	properties_shortcut.set_shortcut(InputMap.get_action_list("ui_properties")[0])
	
	popup = get_popup()
	popup.add_item("Properties...")
	popup.set_item_shortcut(0, properties_shortcut)
	
	themeSubMenu = PopupMenu.new()
	themeSubMenu.set_name("themeSubMenu")
	themeSubMenu.add_radio_check_item("Light")
	themeSubMenu.set_item_checked(0, true)
	themeSubMenu.add_radio_check_item("Dark")
	themeSubMenu.set_item_checked(1, false)
	popup.add_child(themeSubMenu)
	popup.add_submenu_item("Theme", "themeSubMenu")
	
	#advancedSubMenu = PopupMenu.new()
	#advancedSubMenu.set_name("advancedSubMenu")
	#advancedSubMenu.add_item("Save VMF...")
	#popup.add_child(advancedSubMenu)
	#popup.add_submenu_item("Advanced", "advancedSubMenu")
	
	# warning-ignore:return_value_discarded
	popup.connect("id_pressed", self, "_on_item_pressed")
	#advancedSubMenu.connect("id_pressed", self, "_on_item_pressed_advanced")
	# warning-ignore:return_value_discarded
	themeSubMenu.connect("id_pressed", self, "_on_item_pressed_theme")

func __init(themeid: int) -> void:
	self.themeID = themeid
	if self.themeID == Globals.THEME.LIGHT:
		themeSubMenu.set_item_checked(0, true)
		themeSubMenu.set_item_checked(1, false)
		Globals.SET_THEME(Globals.THEME.LIGHT)
	elif self.themeID == Globals.THEME.DARK:
		themeSubMenu.set_item_checked(0, false)
		themeSubMenu.set_item_checked(1, true)
		Globals.SET_THEME(Globals.THEME.DARK)

func get_theme_selection() -> int:
	return self.themeID

func _on_item_pressed(id : int) -> void:
	match id:
		0:
			get_parent().get_parent().get_parent().get_node("Properties").popup_centered()
		_:
			print("Edit says how?")

func _on_item_pressed_theme(id: int) -> void:
	self.themeID = id
	match id:
		0:
			themeSubMenu.set_item_checked(0, true)
			themeSubMenu.set_item_checked(1, false)
			Globals.SET_THEME(Globals.THEME.LIGHT)
			get_parent().get_parent().get_parent().get_node("Properties").save()
		1:
			themeSubMenu.set_item_checked(0, false)
			themeSubMenu.set_item_checked(1, true)
			Globals.SET_THEME(Globals.THEME.DARK)
			get_parent().get_parent().get_parent().get_node("Properties").save()
		_:
			print("Edit.Theme says how?")

func _on_item_pressed_advanced(id: int) -> void:
	match id:
		0:
			print("(Save VMF...) was pressed")
		_:
			print("Edit.Advanced says how?")
