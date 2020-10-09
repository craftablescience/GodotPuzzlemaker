extends MenuButton


var popup: PopupMenu


func _ready() -> void:
	popup = get_popup()
	popup.add_item("New")
	popup.add_item("Open...")
	popup.add_item("Save")
	popup.add_item("Save As...")
	popup.add_item("Exit")
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(id : int) -> void:
	match id:
		0:
			print("(New) was pressed")
		1:
			print("(Open...) was pressed")
		2:
			print("(Save) was pressed")
		3:
			print("(Save As...) was pressed")
		4:
			print("Add a save confirmation dialog later!!")
			get_tree().quit(0)
		_:
			print("File says how?")
