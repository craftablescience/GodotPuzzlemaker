extends Panel


export(float) var anchorLeft: float
export(float) var anchorRight: float
export(float) var anchorLeftHidden: float
export(float) var anchorRightHidden: float

var tween: Tween


func _ready() -> void:
	self.anchor_left = anchorLeftHidden
	self.anchor_right = anchorRightHidden
	self.tween = get_node("Tween")


func _on_button_mouse_entered(buttonID: int) -> void:
	tween.interpolate_property(self, "anchor_left", null, self.anchorLeft, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "anchor_right", null, self.anchorRight, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()

func _on_button_mouse_exited(buttonID: int) -> void:
	tween.interpolate_property(self, "anchor_left", null, self.anchorLeftHidden, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "anchor_right", null, self.anchorRightHidden, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
