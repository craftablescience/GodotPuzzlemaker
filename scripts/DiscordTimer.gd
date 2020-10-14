extends Timer


func _on_timeout() -> void:
	if OS.get_name() == "Windows":
		Globals.DISCORD.details = "Editing Untitled"
		Globals.DISCORD.update()
