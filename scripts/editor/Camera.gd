extends Camera


const MOUSE_SENSITIVITY: float = 0.02
const MOVEMENT_SENSITIVITY: float = 1.0

var active_toggle: bool
var active_button: bool

var pivot: Spatial

signal editor_camera_active
signal editor_camera_inactive


func _ready() -> void:
	active_toggle = false
	active_button = false
	pivot = get_parent()

func _process(_delta: float) -> void:
	# Get movement keys,
	var vec3: Vector3 = Vector3()
	if (Input.is_action_pressed("editor_camera_forward")):
		vec3 -= self.transform.basis.z
	if (Input.is_action_pressed("editor_camera_back")):
		vec3 += self.transform.basis.z
	if (Input.is_action_pressed("editor_camera_left")):
		vec3 -= self.transform.basis.x
	if (Input.is_action_pressed("editor_camera_right")):
		vec3 += self.transform.basis.x
	if (Input.is_action_pressed("editor_camera_up")):
		vec3.y += 1
	if (Input.is_action_pressed("editor_camera_down")):
		vec3.y -= 1
	vec3 = vec3.normalized() * MOVEMENT_SENSITIVITY
	
	# Activate movement?
	if Input.is_action_just_pressed("editor_camera_button"):
		active_button = true
		active_toggle = false
	if Input.is_action_just_released("editor_camera_button"):
		active_button = false
	if Input.is_action_just_pressed("editor_camera_toggle") and !active_button:
		active_toggle = !active_toggle
	
	if (!(active_toggle or active_button)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		self.emit_signal("editor_camera_inactive")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.emit_signal("editor_camera_active")
	
	if (active_toggle or active_button):
		pivot.translate(vec3)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		# Rotate the camera..
		if (active_toggle or active_button):
			pivot.rotate_y(deg2rad(-event.relative.x * MOUSE_SENSITIVITY))
			self.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
			self.rotation_degrees.x = clamp(self.rotation_degrees.x, -90, 90)
