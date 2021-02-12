extends "res://scripts/editor/ToolBarUpDown.gd"


var x: Label
var y: Label
var gi: Label
var sn: Label
var xs: Slider
var ys: Slider
var gis: Slider
var sns: Slider
var sunBtn: Button
var giBtn: Button


func _ready() -> void:
	self.x = $LabelX
	self.y = $LabelY
	self.gi = $LabelGI
	self.sn = $LabelSun
	self.xs = $XSlider
	self.ys = $YSlider
	self.gis = $GISlider
	self.sns = $SunSlider
	self.sunBtn = $SunEnable
	self.giBtn = $GIEnable


func __init(sunOn: bool, giOn: bool, xi: int, yi: int, gii: int, sni: int) -> void:
	self.sunBtn.pressed = sunOn
	self.giBtn.pressed = giOn
	self.xs.value = xi
	self.ys.value = yi
	self.gis.value = gii
	self.sns.value = sni
	self.update()

func update() -> void:
	self.x.text  = "Pitch: " + str(int(self.xs.value))  + "°"
	self.y.text  = "Yaw: "   + str(int(self.ys.value))  + "°"
	self.gi.text = "GI: "    + str(int(self.gis.value)) + "%"
	self.sn.text = "Sun: "   + str(int(self.sns.value)) + "%"
	
	var roomSun: DirectionalLight = get_parent().get_parent().get_parent().get_node("Scene/Room/Sun")
	if self.sunBtn.pressed:
		roomSun.light_energy = float(self.sns.value) / 100.0
		roomSun.show()
	else:
		roomSun.hide()
	roomSun.rotation_degrees.x = int(self.xs.value)
	roomSun.rotation_degrees.y = int(self.ys.value)
	roomSun.rotation_degrees.z = 0
	var env: Environment = get_parent().get_parent().get_parent().get_node("Environment").environment
	if self.giBtn.pressed:
		env.ambient_light_energy = float(self.gis.value) / 100.0
	else:
		env.ambient_light_energy = 0.0


func _on_XSlider_value_changed(_value: float) -> void:
	self.update()

func _on_YSlider_value_changed(_value: float) -> void:
	self.update()

func _on_GISlider_value_changed(_value: float) -> void:
	self.update()

func _on_SunSlider_value_changed(_value: float) -> void:
	self.update()

func _on_SunEnable_toggled(_button_pressed: bool) -> void:
	self.update()

func _on_GIEnable_toggled(_button_pressed: bool) -> void:
	self.update()
