extends Panel


export(float) var anchorUp: float
export(float) var anchorDown: float
export(float) var anchorUpHidden: float
export(float) var anchorDownHidden: float

var tween: Tween


func _ready() -> void:
	self.anchor_top = anchorUpHidden
	self.anchor_bottom = anchorDownHidden
	self.tween = get_node("Tween")


func _on_grow() -> void:
	tween.interpolate_property(self, "anchor_top", null, self.anchorUp, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "anchor_bottom", null, self.anchorDown, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()

func _on_shrink() -> void:
	tween.interpolate_property(self, "anchor_top", null, self.anchorUpHidden, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "anchor_bottom", null, self.anchorDownHidden, 0.25, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
