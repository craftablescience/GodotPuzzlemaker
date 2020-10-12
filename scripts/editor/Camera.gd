extends Camera


const MOUSE_SENSITIVITY: float = 0.02
const MOBILE_SENSITIVITY: float = 32.0
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

func get_movement() -> Vector3:
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
	return vec3

func get_mobile_movement(key) -> Vector3:
	# Get movement keys,
	var vec3: Vector3 = Vector3()
	if (key == KEY_W):
		vec3 -= self.transform.basis.z
	elif (key == KEY_S):
		vec3 += self.transform.basis.z
	elif (key == KEY_A):
		vec3 -= self.transform.basis.x
	elif (key == KEY_D):
		vec3 += self.transform.basis.x
	elif (key == KEY_SPACE):
		vec3.y += 1
	elif (key == KEY_C):
		vec3.y -= 1
	vec3 = vec3.normalized() * MOVEMENT_SENSITIVITY
	return vec3

func _process(_delta) -> void:
	if (active_toggle or active_button):
		pivot.translate(self.get_movement())

func _input(event: InputEvent) -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotate the camera..
		if active_toggle or active_button:
			pivot.rotate_y(deg2rad(-event.relative.x * MOUSE_SENSITIVITY))
			self.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
			self.rotation_degrees.x = clamp(self.rotation_degrees.x, -90, 90)
	elif event is InputEventKey:
		if !event.scancode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
			pivot.translate(self.get_mobile_movement(event.scancode))
		else:
			var x: float = 0.0
			var y: float = 0.0
			if event.scancode == KEY_UP:
				y = MOBILE_SENSITIVITY
			elif event.scancode == KEY_DOWN:
				y = -MOBILE_SENSITIVITY
			elif event.scancode == KEY_LEFT:
				x = MOBILE_SENSITIVITY
			elif event.scancode == KEY_RIGHT:
				x = -MOBILE_SENSITIVITY
			pivot.rotate_y(deg2rad(x * MOUSE_SENSITIVITY))
			self.rotate_x(deg2rad(y * MOUSE_SENSITIVITY))
			self.rotation_degrees.x = clamp(self.rotation_degrees.x, -90, 90)
