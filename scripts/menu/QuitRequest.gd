extends ConfirmationDialog


func _on_confirmed():
	for file in Globals.LIST_FILES_IN_DIR("user://.cache/"):
		var d: Directory = Directory.new()
		# warning-ignore:return_value_discarded
		d.remove("user://.cache/" + file)
	get_tree().quit(0)
