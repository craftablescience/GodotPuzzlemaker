extends Control


var btn
var fwd: bool
var bck: bool
var lft: bool
var rgt: bool
var up:  bool
var dwn: bool
var llft: bool
var lrgt: bool
var lup:  bool
var ldwn: bool


func _ready() -> void:
	self.hide()
	self.btn = BUTTON_LEFT
	get_node("LeftClick").disabled = true
	self.fwd = false
	self.bck = false
	self.lft = false
	self.rgt = false
	self.up  = false
	self.dwn = false
	self.llft = false
	self.lrgt = false
	self.lup  = false
	self.ldwn = false

func _process(delta: float) -> void:
	if self.fwd:
		self.create_key_event(KEY_W)
	if self.bck:
		self.create_key_event(KEY_S)
	if self.lft:
		self.create_key_event(KEY_A)
	if self.rgt:
		self.create_key_event(KEY_D)
	if self.up:
		self.create_key_event(KEY_SPACE)
	if self.dwn:
		self.create_key_event(KEY_C)

	if self.llft:
		self.create_key_event(KEY_LEFT)
	if self.lrgt:
		self.create_key_event(KEY_RIGHT)
	if self.lup:
		self.create_key_event(KEY_UP)
	if self.ldwn:
		self.create_key_event(KEY_DOWN)


func create_mouse_event(event: InputEventMouseButton) -> void:
	var ev = event
	ev.button_index = self.btn
	get_tree().input_event(ev)

func create_key_event(key) -> void:
	var ev = InputEventKey.new()
	ev.scancode = key
	ev.pressed = true
	get_tree().input_event(ev)

func _input(event: InputEvent) -> void:
	if self.visible:
		if event is InputEventMouseButton and event.button_index != self.btn:
			self.create_mouse_event(event)
			get_tree().set_input_as_handled()

func _on_Mobile_toggled(button_pressed: bool) -> void:
	if button_pressed:
		self.show()
	else:
		self.hide()

func _on_LeftClick_pressed() -> void:
	get_node("LeftClick").disabled = true
	get_node("RightClick").disabled = false
	self.btn = BUTTON_LEFT

func _on_RightClick_pressed() -> void:
	get_node("LeftClick").disabled = false
	get_node("RightClick").disabled = true
	self.btn = BUTTON_RIGHT


func _on_Forward_button_down() -> void:
	self.fwd = true
func _on_Forward_button_up() -> void:
	self.fwd = false

func _on_Back_button_down() -> void:
	self.bck = true
func _on_Back_button_up() -> void:
	self.bck = false

func _on_Left_button_down() -> void:
	self.lft = true
func _on_Left_button_up() -> void:
	self.lft = false

func _on_Right_button_down() -> void:
	self.rgt = true
func _on_Right_button_up() -> void:
	self.rgt = false

func _on_Up_button_down() -> void:
	self.up = true
func _on_Up_button_up() -> void:
	self.up = false

func _on_Down_button_down() -> void:
	self.dwn = true
func _on_Down_button_up() -> void:
	self.dwn = false


func _on_LookUp_button_down() -> void:
	self.lup = true
func _on_LookUp_button_up() -> void:
	self.lup = false

func _on_LookDown_button_down() -> void:
	self.ldwn = true
func _on_LookDown_button_up() -> void:
	self.ldwn = false

func _on_LookLeft_button_down() -> void:
	self.llft = true
func _on_LookLeft_button_up() -> void:
	self.llft = false

func _on_LookRight_button_down() -> void:
	self.lrgt = true
func _on_LookRight_button_up() -> void:
	self.lrgt = false
