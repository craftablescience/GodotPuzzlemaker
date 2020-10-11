extends ConfirmationDialog


signal clear


func _ready() -> void:
	self.connect("clear", get_parent().get_parent().get_parent().get_node("Scene/Room"), "clear")

func _on_confirmed():
	self.emit_signal("clear")
