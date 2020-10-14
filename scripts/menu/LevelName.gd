extends LineEdit


func _ready():
	self.connect("focus_entered", self, "_on_focus")

func _on_focus():
	if OS.get_name() == "HTML5" and get_parent().get_node("Mobile").visible and get_parent().get_node("Mobile").pressed:
		self.text = JavaScript.eval("prompt('%s', '%s');" % ["Please enter text:", text], true)
		self.release_focus()

func _on_text_changed(text: String) -> void:
	if text != "":
		Globals.DISCORD.details = "Editing " + text + ".gpz"
	else:
		Globals.DISCORD.details = "Editing Untitled"
	Globals.DISCORD.update()
