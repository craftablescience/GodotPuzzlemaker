extends ConfirmationDialog


signal clear


func _ready() -> void:
	# warning-ignore:return_value_discarded
	self.connect("clear", get_parent().get_parent().get_parent().get_node("Scene/Room"), "clear")

func _on_confirmed():
	self.emit_signal("clear")
