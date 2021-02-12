extends "res://addons/vmflib/VMFRoot.gd"
class_name VMF

var versioninfo: VersionInfo
var visgroups: VisGroups
var viewsettings: ViewSettings
var world: ValveWorld
var cameras: Cameras
var cordons: Cordons

var COMMON_MATERIALS: Materials.Common

var game_path: String


enum GAMES {
	PORTAL_2
}


func _init(game: int = GAMES.PORTAL_2).(""):
	self.COMMON_MATERIALS = Materials.Common.new()
	
	self.versioninfo = VersionInfo.new()
	self.visgroups = VisGroups.new()
	self.viewsettings = ViewSettings.new()
	self.cameras = Cameras.new()
	self.cordons = Cordons.new()
	
	self.children.append(self.versioninfo)
	self.children.append(self.visgroups)
	self.children.append(self.viewsettings)
	self.world = ValveWorld.new(self, game) # Automatically added to children
	

func add_solid(solid):
	self.world.children.append(solid)

func add_solids(solids):
	for s in solids:
		self.add_solid(s)

func write_vmf(filename: String = "user://output.vmf"):
	self.children.append(self.cameras)
	self.children.append(self.cordons)
	var f: File = File.new()
	f.open(filename, File.WRITE)
	f.store_string(self.getAsStr())
	f.close()
	self.children.erase(self.cameras)
	self.children.erase(self.cordons)

func _to_string() -> String:
	self.children.append(self.cameras)
	self.children.append(self.cordons)
	return self.getAsStr()
	self.children.erase(self.cameras)
	self.children.erase(self.cordons)


# -v- HELPER CLASSES -v- #

class Vertex:
	var x: int
	var y: int
	var z: int
	var parenthesis: bool
	func _init(x: int = 0, y: int = 0, z: int = 0, show_parenthesis: bool = true) -> void:
		self.x = x
		self.y = y
		self.z = z
		self.parenthesis = show_parenthesis
	func setParenthesis(enabled: bool):
		self.parenthesis = enabled
	func getX() -> int:
		return self.x
	func getY() -> int:
		return self.y
	func getZ() -> int:
		return self.z
	func getAsStr() -> String:
		if parenthesis:
			return "(" + str(self.x) + " " + str(self.y) + " " + str(self.z) + ")"
		else:
			return str(self.x) + " " + str(self.y) + " " + str(self.z)
	func _to_string() -> String:
		return self.getAsStr()
	func add(other: Vertex):
		return Vertex.new(self.x + other.x, self.y + other.y, self.z + other.z)
	func subtract(other: Vertex) -> Vertex:
		return Vertex.new(self.x - other.x, self.y - other.y, self.z - other.z)
	func multiply(other: int) -> Vertex:
		return Vertex.new(self.x * other, self.y * other, self.z * other)


class Axis:
	var x: int
	var y: int
	var z: int
	var translat: int
	var scale: int
	func _init(x: int = 0, y: int = 0, z: int = 0, translat: int = 0, scale: float = 0.25) -> void:
		self.x = x
		self.y = y
		self.z = z
		self.translat = translat
		self.scale = scale
	func getAsStr() -> String:
		return "[" + str(self.x) + " " + str(self.y) + " " + str(self.z) + " " + str(self.translat) + "] " + str(self.scale)
	func _to_string() -> String:
		return self.getAsStr()


class RGB:
	var r: int
	var g: int
	var b: int
	var a: int
	func _init(r: int = 0, g: int = 0, b: int = 0, a: int = -1) -> void:
		self.r = int(r)
		self.g = int(g)
		self.b = int(b)
		self.a = int(a)
	func getAsStr() -> String:
		if a < 0:
			return str(r) + " " + str(g) + " " + str(b)
		else:
			return str(r) + " " + str(g) + " " + str(b) + " " + str(a)
	func _to_string() -> String:
		return self.getAsStr()


class Bool:
	var state: bool
	func _init(state: bool = false) -> void:
		self.state = state
	func getAsStr() -> String:
		return str(int(bool(self.state)))
	func _to_string() -> String:
		return self.getAsStr()


class ValvePlane:
	var v0: Vertex
	var v1: Vertex
	var v2: Vertex
	func _init(v0: Vertex = Vertex.new(), v1: Vertex = Vertex.new(), v2: Vertex = Vertex.new()):
		self.v0 = v0
		self.v1 = v1
		self.v2 = v2
	func getAsStr() -> String:
		return v0.getAsStr() + " " + v1.getAsStr() + " " + v2.getAsStr()
	func _to_string() -> String:
		return self.getAsStr()
	func sensible_axes() -> Array:
		"""Returns a sensible uaxis and vaxis for this plane."""
		# TODO: Rewrite this method to allow non-90deg planes to work
		# Figure out which axes the plane exists in
		var axes: Array = [1, 1, 1]
		if self.v0.x == self.v1.x and self.v0.x == self.v2.x and self.v1.x == self.v2.x:
			axes[0] = 0
		if self.v0.y == self.v1.y and self.v0.y == self.v2.y and self.v1.y == self.v2.y:
			axes[1] = 0
		if self.v0.z == self.v1.z and self.v0.z == self.v2.z and self.v1.z == self.v2.z:
			axes[2] = 0
		var u: Array = [0, 0, 0]
		for i in range(3):
			if axes[i] == 1:
				u[i] = 1
				axes[i] = 0
				break
		var v: Array = [0, 0, 0]
		for i in range(3):
			if axes[i] == 1:
				v[i] = -1
				break
		var uaxis: Axis = Axis.new(u[0], u[1], u[2])
		var vaxis: Axis = Axis.new(v[0], v[1], v[2])
		return [uaxis, vaxis]


class Output:
	var event
	var target
	var input
	var parameter: String
	var delay: int
	var times_to_fire: int
	func _init(event, target, input, parameter: String = "", delay: int = 0, times_to_fire: int = -1):
		self.event = event
		self.target = target
		self.input = input
		self.parameter = parameter
		self.delay = delay
		self.times_to_fire = times_to_fire
	func getAsStr() -> String:
		return "\"" + self.event + "\" \"" + self.target + "," + self.input + "," + self.parameter + "," + self.delay + "," + self.times_to_fire + "\""
	func _to_string() -> String:
		return self.getAsStr()


class VersionInfo extends "res://addons/vmflib/VMFRoot.gd":
	func _init().("versioninfo") -> void:
		self.properties["editorversion"] = 400
		self.properties["editorbuild"] = 8419
		self.properties["mapversion"] = 0
		self.properties["formatversion"] = 100
		self.properties["prefab"] = 0


class VisGroups extends "res://addons/vmflib/VMFRoot.gd":
	func _init().("visgroups") -> void:
		pass


class ViewSettings extends "res://addons/vmflib/VMFRoot.gd":
	var bSnapToGrid: Bool
	var bShowGrid: Bool
	var bShowLogicalGrid: Bool
	var nGridSpacing: int
	var bShow3DGrid: Bool
	func _init(grid_snap: bool = true, grid_visible: bool = true, grid_spacing: int = 64, grid_3d_visible: bool = false).("viewsettings") -> void:
		self.bSnapToGrid = Bool.new(grid_snap)
		self.bShowGrid = Bool.new(grid_visible)
		self.bShowLogicalGrid = Bool.new()
		self.nGridSpacing = grid_spacing
		self.bShow3DGrid = Bool.new(grid_3d_visible)
		self.auto_properties.append("bSnapToGrid")
		self.auto_properties.append("bShowGrid")
		self.auto_properties.append("bShowLogicalGrid")
		self.auto_properties.append("nGridSpacing")
		self.auto_properties.append("bShow3DGrid")


class Cameras extends "res://addons/vmflib/VMFRoot.gd":
	var activecamera: String
	func _init().("cameras") -> void:
		self.activecamera = "-1"
		self.auto_properties.append("activecamera")


class Cordons extends "res://addons/vmflib/VMFRoot.gd":
	var active: Bool
	func _init().("cordons") -> void:
		self.active = Bool.new(0)
		self.auto_properties = ['active']


class Entity extends "res://addons/vmflib/VMFRoot.gd":
	var classname: String
	var connections: Connections
	func _init(className: String, vmf_map, super_name: String = "entity").(super_name):
		self.classname = className
		self.connections = null
		self.properties['id'] = VMFDataManager.ENTITY_COUNT
		self.properties['classname'] = self.classname
		VMFDataManager.ENTITY_COUNT += 1
		vmf_map.children.append(self)
	func add_output(output) -> void:
		if self.connections == null:
			self.connections = Connections.new()
			self.children.append(self.connections)
		self.connections.children.append(output)
	func add_outputs(outputs) -> void:
		for o in outputs:
			self.add_output(o)


class Connections extends "res://addons/vmflib/VMFRoot.gd":
	func _init().("connections") -> void:
		pass
	func getAsStr(tab_level: int = -1) -> String:
		var string: String = ""
		var tab_prefix: String = ""
		for i in range(tab_level):
			tab_prefix += "\t"
		var tab_prefix_inner: String = tab_prefix + "\t"
		if (self.vmf_class_name):
			string += tab_prefix + self.vmf_class_name + "\n"
			string += tab_prefix + "{\n"
		for output in self.children:
			string += tab_prefix_inner + output + "\n"
		if (self.vmf_class_name):
			string += tab_prefix + "}\n"
		return string
	func _to_string() -> String:
		return self.getAsStr()


class ValveWorld extends Entity:
	var skyname: String
	var detailmaterial: String
	var detailvbsp: String
	var maxblobcount: int
	var maxpropscreenwidth: int
	func _init(vmf_map, game: int).("worldspawn",vmf_map,"world") -> void:
		match game:
			GAMES.PORTAL_2:
				self.skyname = "sky_black_nofog"
				self.detailmaterial = "detail/detailsprites"
				self.detailvbsp = "detail.vbsp"
				self.maxblobcount = 250
				self.maxpropscreenwidth = -1
				self.auto_properties.append("skyname")
				self.auto_properties.append("detailmaterial")
				self.auto_properties.append("detailvbsp")
				self.auto_properties.append("maxblobcount")
				self.auto_properties.append("maxpropscreenwidth")
			_:
				assert(!(game > GAMES.size() - 1 or game < GAMES.size()), "Must be a valid game")
		self.properties['id'] = VMFDataManager.WORLD_COUNT
		VMFDataManager.WORLD_COUNT += 1
		self.properties['mapversion'] = 0


class Solid extends "res://addons/vmflib/VMFRoot.gd":
	func _init().("solid") -> void:
		self.auto_properties = []
		self.properties['id'] = VMFDataManager.SOLID_COUNT
		VMFDataManager.SOLID_COUNT += 1


class Side extends "res://addons/vmflib/VMFRoot.gd":
	var plane: ValvePlane
	var material: String
	var rotation: int
	var lightmapscale: int
	var smoothing_groups: int
	var uaxis: Axis
	var vaxis: Axis
	func _init(plane: ValvePlane = ValvePlane.new(), material: String = "BRICK/BRICKFLOOR001A").("side"):
		self.plane = plane
		self.material = material
		self.rotation = 0
		self.lightmapscale = 16
		self.smoothing_groups = 0
		self.uaxis = Axis.new()
		self.vaxis = Axis.new()
		self.auto_properties = ["plane", "material", "uaxis", "vaxis", "rotation", "lightmapscale", "smoothing_groups"]
		self.properties['id'] = VMFDataManager.SIDE_COUNT # in og code uses brush count
		VMFDataManager.SIDE_COUNT += 1


class Group extends "res://addons/vmflib/VMFRoot.gd":
	func _init().("group"):
		self.auto_properties = []
		self.properties['id'] = VMFDataManager.GROUP_COUNT
		VMFDataManager.GROUP_COUNT += 1

# DispInfo ; Offsets ; OffestNormals ; TriangleTags ; AllowedVerts
# not included

class Normals extends "res://addons/vmflib/VMFRoot.gd":
	func _init(power, values).("normals"):
		for i in range(pow(2, power) + 1):
			var row_string = ""
			for vert in values[i]:
				row_string += str(vert.x) + " " + str(vert.y) + " " + str(vert.z)
			self.properties["row" + str(i)] = row_string


class Distances extends "res://addons/vmflib/VMFRoot.gd":
	var values
	func _init(power, values).("distances"):
		self.values = values
		for i in range(pow(2, power) + 1):
			var row_string = ""
			for distance in values[i]:
				row_string += str(distance) + " "
			self.properties["row" + str(i)] = row_string.strip_edges(false, true)


class Alphas extends "res://addons/vmflib/VMFRoot.gd":
	func _init(power, values = null).("alphas"):
		if values != null:
			for i in range(pow(2, power) + 1):
				var row_string = ""
				for distance in values[i]:
					row_string += str(distance) + " "
				self.properties["row" + str(i)] = row_string.strip_edges(false, true)


class Block:
	var origin: Vertex
	var dimensions: Array
	var brush: Solid
	func _init(origin: Vector3 = Vector3(), dimensions: Vector3 = Vector3(64, 64, 64), material: String = VMFDataManager.DEFAULT_MATERIAL) -> void:
		self.origin = Vertex.new(origin.x, origin.z, origin.y)
		self.dimensions = [dimensions.x, dimensions.z, dimensions.y]
		self.brush = Solid.new()
		for i in range(6):
			self.brush.children.append(Side.new(ValvePlane.new(), material))
		self.update_sides()
		self.set_material(material)
	func update_sides() -> void:
		var x = self.origin.x
		var y = self.origin.y
		var z = self.origin.z
		var w = self.dimensions[0]
		var l = self.dimensions[1]
		var h = self.dimensions[2]
		var a = w / 2
		var b = l / 2
		var c = h / 2
		self.brush.children[0].plane = ValvePlane.new(
			Vertex.new(x - a, y + b, z + c),
			Vertex.new(x + a, y + b, z + c),
			Vertex.new(x + a, y - b, z + c))
		self.brush.children[1].plane = ValvePlane.new(
			Vertex.new(x - a, y - b, z - c),
			Vertex.new(x + a, y - b, z - c),
			Vertex.new(x + a, y + b, z - c))
		self.brush.children[2].plane = ValvePlane.new(
			Vertex.new(x - a, y + b, z + c),
			Vertex.new(x - a, y - b, z + c),
			Vertex.new(x - a, y - b, z - c))
		self.brush.children[3].plane = ValvePlane.new(
			Vertex.new(x + a, y + b, z - c),
			Vertex.new(x + a, y - b, z - c),
			Vertex.new(x + a, y - b, z + c))
		self.brush.children[4].plane = ValvePlane.new(
			Vertex.new(x + a, y + b, z + c),
			Vertex.new(x - a, y + b, z + c),
			Vertex.new(x - a, y + b, z - c))
		self.brush.children[5].plane = ValvePlane.new(
			Vertex.new(x + a, y - b, z - c),
			Vertex.new(x - a, y - b, z - c),
			Vertex.new(x - a, y - b, z + c))
		for side in self.brush.children:
			var axes: Array = side.plane.sensible_axes()
			side.uaxis = axes[0]
			side.vaxis = axes[1]
	func set_material(material: String) -> void:
		for side in self.brush.children:
			side.material = material
	func set_material_side(material: String, side: Vector3) -> Block:
		match side:
			Vector3.UP:
				self.brush.children[0].material = material
			Vector3.DOWN:
				self.brush.children[1].material = material
			Vector3.BACK:
				self.brush.children[2].material = material
			Vector3.FORWARD:
				self.brush.children[3].material = material
			Vector3.LEFT:
				self.brush.children[4].material = material
			Vector3.RIGHT:
				self.brush.children[5].material = material
			_:
				assert(false, "Vector3 passed must be Vector3.UP, Vector3.DOWN, etc.")
		return self
	# TODO: set material on side
	# TODO: other side getters
	func bottom() -> Side:
		return self.brush.children[1]
	func top() -> Side:
		return self.brush.children[0]
	func getAsStr(tab_level: int = -1) -> String:
		return self.brush.getAsStr(tab_level)
	func _to_string() -> String:
		return self.getAsStr()

# Other classes in tools.py excluded

class Entities:
	# Entities that can be added to the map
	# TODO: Add the rest of the relevant entities
	class Common:
		class InfoPlayerStartEntity extends Entity:
			var origin: Vertex
			var angles: Vertex
			func _init(vmf_map, origin: Vector3 = Vector3(), angles: Vector3 = Vector3()).("info_player_start",vmf_map):
				self.origin = Vertex.new(origin.x, origin.z, origin.y)
				self.origin.setParenthesis(false)
				self.angles = Vertex.new(angles.x, angles.z, angles.y)
				self.angles.setParenthesis(false)
				self.auto_properties.append("origin")
				self.auto_properties.append("angles")
		
		class LightEntity extends Entity:
			var origin: Vertex
			var targetname: String
			var _light: RGB
			var _lightHDR: RGB
			var _lightscaleHDR: float
			var style: int
			var pattern: String
			var _constant_attn: Bool
			var _linear_attn: Bool
			var _quadratic_attn: Bool
			var _fifty_percent_distance: Bool
			var _zero_percent_distance: Bool
			var _hardfalloff: int
			var target: String
			var _distance: int
			func _init(vmf_map, origin: Vector3 = Vector3(), \
						targetname: String = "", _light: RGB = RGB.new(255,255,255,200), \
						_lightHDR: RGB = RGB.new(-1,-1,-1,1), _lightscaleHDR: float = 1, \
						style: int = 0, pattern: String = "", _constant_attn: Bool = Bool.new(), \
						_linear_attn: Bool = Bool.new(), _quadratic_attn: Bool = Bool.new(true), \
						_fifty_percent_distance: Bool = Bool.new(), _zero_percent_distance: Bool = Bool.new(), \
						_hardfalloff: int = 0, target: String = "", _distance: int = 0).("light",vmf_map):
				self.origin = Vertex.new(origin.x, origin.z, origin.y)
				self.origin.setParenthesis(false)
				self.targetname = targetname
				self._light = _light
				self._lightHDR = _lightHDR
				self._lightscaleHDR = _lightscaleHDR
				self.style = style
				self.pattern = pattern
				self._constant_attn = _constant_attn
				self._linear_attn = _linear_attn
				self._quadratic_attn = _quadratic_attn
				self._fifty_percent_distance = _fifty_percent_distance
				self._zero_percent_distance = _zero_percent_distance
				self._hardfalloff = _hardfalloff
				self.target = target
				self._distance = _distance
				for prop in ["origin", "targetname",\
							 "_light", "_lightHDR",\
							 "_lightscaleHDR", "style",\
							 "pattern", "_constant_attn",\
							 "_linear_attn", "_quadratic_attn",\
							 "_fifty_percent_distance", "_zero_percent_distance",\
							 "_hardfalloff", "target",\
							 "spawnflags", "_distance"]:
					self.auto_properties.append(prop)


class Materials:
	# Materials to texture brush faces
	# TODO: add the rest of the materials
	class Common:
		var TOOLS_TOOLSNODRAW = "TOOLS/TOOLSNODRAW"
		var DEV_MEASUREWALL01A = "DEV/DEV_MEASUREWALL01A"
