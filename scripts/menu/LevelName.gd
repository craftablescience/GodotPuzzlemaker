extends LineEdit


func _ready():
	self.connect("focus_entered", self, "js_text_entry")

func js_text_entry():
	if OS.get_name() == "HTML5" and get_parent().get_node("Mobile").visible and get_parent().get_node("Mobile").pressed:
		self.text = JavaScript.eval("prompt('%s', '%s');" % ["Please enter text:", text], true)
		self.release_focus()
