extends MenuButton


var popup: PopupMenu


func _ready() -> void:
	popup = get_popup()
	popup.add_item("Report an issue")
	popup.add_item("Request a feature")
	
	# warning-ignore:return_value_discarded
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id : int) -> void:
	match id:
		0:
			# warning-ignore:return_value_discarded
			OS.shell_open("https://github.com/craftablescience/GodotPuzzlemaker/issues/new?assignees=craftablescience&labels=bug&template=bug-report.md&title=%5BBUG%5D+Name+of+issue+here")
		1:
			# warning-ignore:return_value_discarded
			OS.shell_open("https://github.com/craftablescience/GodotPuzzlemaker/issues/new?assignees=craftablescience&labels=enhancement&template=feature-request.md&title=%5BFEATURE%5D+Name+of+feature+idea+here")
		_:
			assert(false, "Feedback says how?")
