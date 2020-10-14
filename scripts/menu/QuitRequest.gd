extends ConfirmationDialog


func _on_confirmed():
	for file in Globals.LIST_FILES_IN_DIR("user://.cache/"):
		var d: Directory = Directory.new()
		d.remove("user://.cache/" + file)
	get_tree().quit(0)
