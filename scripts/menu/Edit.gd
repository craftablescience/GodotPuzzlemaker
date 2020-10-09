extends MenuButton


var popup: PopupMenu
var advancedSubMenu: PopupMenu


func _ready() -> void:
	popup = get_popup()
	popup.add_item("Properties...")
	popup.add_item("Set Theme...")
	popup.add_item("Compile")
	popup.add_item("Compile + Run")
	
	advancedSubMenu = PopupMenu.new()
	advancedSubMenu.set_name("advancedSubMenu")
	advancedSubMenu.add_item("Save VMF...")
	popup.add_child(advancedSubMenu)
	popup.add_submenu_item("Advanced", "advancedSubMenu")
	
	popup.connect("id_pressed", self, "_on_item_pressed")
	advancedSubMenu.connect("id_pressed", self, "_on_item_pressed_advanced")

func _on_item_pressed(id : int) -> void:
	match id:
		0:
			print("(Properties) was pressed")
		1:
			print("(Set Theme) was pressed")
		2:
			print("(Compile) was pressed")
		3:
			print("(Compile + Run) was pressed")
		_:
			print("Edit says how?")

func _on_item_pressed_advanced(id: int) -> void:
	match id:
		0:
			print("(Save VMF...) was pressed")
		_:
			print("Edit.Advanced says how?")
