extends AudioStreamPlayer


onready var isDisabled = false


func get_disabled() -> bool:
	return self.isDisabled

func set_disabled(b: bool) -> void:
	self.isDisabled = b
