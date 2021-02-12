extends Button


var player: KinematicBody
var room: Spatial


signal play_button_pressed


func _ready() -> void:
	self.text = " Play"
	self.room = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Scene/Room")
	self.player = self.room.get_node("Player")
	self.player.hide()


func _on_toggled(button_pressed: bool) -> void:
	self.release_focus()
	if button_pressed:
		self.emit_signal("play_button_pressed")
		var resp: Array = self.room.get_player_start()
		if !resp[0]:
			get_parent().get_parent().get_parent().get_node("PlayModeError").popup_centered()
			self.player._set_active(false)
			self.player.hide()
		else:
			self.text = " Stop"
			Globals.PLAY_MODE = true
			self.player.global_transform.origin.x = resp[1]
			self.player.global_transform.origin.y = resp[2]
			self.player.global_transform.origin.z = resp[3]
			self.player._set_active(true)
			self.player.show()
	else:
		self.text = " Play"
		Globals.PLAY_MODE = false
		self.player._set_active(false)
		self.player.hide()
