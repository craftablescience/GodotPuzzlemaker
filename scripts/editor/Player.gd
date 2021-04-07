extends KinematicBody


var active: bool
var esc_pressed: bool
var cam: Camera
var gravity: float
var movement: Vector3


func _ready() -> void:
	self.active = false
	self.cam = $Camera
	self.esc_pressed = false
	self.gravity = -10.0
	self.movement = Vector3()

func _i_am_the_player_fear_me_() -> void:
	pass # very convoluted (but in a few lines) way of telling player apart from other nodes

# warning-ignore:shadowed_variable
func _set_active(active: bool) -> void:
	self.active = active
	LogicManager.set_active(active)
	if active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.esc_pressed = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if self.active and Input.is_action_just_pressed("editor_player_pause"):
		if !esc_pressed:
			self.esc_pressed = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			self.esc_pressed = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if self.active:
		if Input.is_action_pressed("editor_camera_forward"):
			self.movement.z = -1
		if Input.is_action_pressed("editor_camera_back"):
			self.movement.z = 1
		if !Input.is_action_pressed("editor_camera_forward") and !Input.is_action_pressed("editor_camera_back"):
			self.movement.z = 0
		if Input.is_action_pressed("editor_camera_left"):
			self.movement.x = -1
		if Input.is_action_pressed("editor_camera_right"):
			self.movement.x = 1
		if !Input.is_action_pressed("editor_camera_left") and !Input.is_action_pressed("editor_camera_right"):
			self.movement.x = 0
	
		var snap: Vector3 = Vector3(0,-0.25,0)
	
		if self.is_on_floor():
			self.movement.y = 0
		else:
			self.movement.y += gravity * delta
	
		if Input.is_action_just_pressed("editor_camera_up") and self.is_on_floor():
			self.movement.y = 4
			snap = Vector3()
	
		# warning-ignore:return_value_discarded
		self.move_and_slide_with_snap(transform.basis.xform(movement) * 20, snap, Vector3(0,1,0))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the camera..
		if self.active and !self.esc_pressed:
			self.rotation_degrees.y -= event.relative.x * Globals.MOUSE_SENSITIVITY
			self.cam.rotation_degrees.x -= event.relative.y * Globals.MOUSE_SENSITIVITY
			if self.cam.rotation_degrees.x < -90:
				self.cam.rotation_degrees.x = -90
			elif self.cam.rotation_degrees.x > 90:
				self.cam.rotation_degrees.x = 90
