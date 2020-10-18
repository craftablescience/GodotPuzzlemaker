extends Timer


func _on_timeout() -> void:
	if OS.get_name() == "Windows" or OS.get_name() == "X11":
		Globals.DISCORD.details = "Editing Untitled"
		Globals.DISCORD.update()
