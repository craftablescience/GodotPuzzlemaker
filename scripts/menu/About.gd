extends MenuButton


var popup: PopupMenu


func _ready() -> void:
	popup = get_popup()
	popup.add_item("Credits")
	if OS.get_name() != "HTML5":
		popup.add_item("Background Music")
	
	# warning-ignore:return_value_discarded
	popup.connect("id_pressed", self, "_on_item_pressed")


func _on_item_pressed(id : int) -> void:
	match id:
		0:
			get_parent().get_parent().get_parent().get_node("Credits").popup_centered()
		1:
			get_parent().get_parent().get_parent().get_node("BackgroundMusicCredits").popup_centered()
		_:
			print("About says how?")
