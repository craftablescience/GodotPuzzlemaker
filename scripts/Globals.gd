extends Node


enum PLANEID {
	XP,
	XM,
	YP,
	YM,
	ZP,
	ZM
}

enum TOOL {
	SELECT,
	VOXEL,
	TEXTURE,
	PLACEENTITY
}

enum THEME {
	LIGHT,
	DARK
}

var MOUSE_SENSITIVITY: float = 0.02
var MOVEMENT_SENSITIVITY: float = 1.0

const MOBILE_SENSITIVITY: float = 32.0

const FIRSTTOOL: int = TOOL.VOXEL

const FILEFORMAT: int = 17
const FILESETTINGSFORMAT: int = 19

const TEXTUREFALLBACK: String = "builtin:white"

var PLAY_MODE: bool = false

const CUSTOMID: String = "usercustom"
const PLAYER_START: String = "player_start"

static func SET_THEME(tm: int) -> void:
	if tm == Globals.THEME.LIGHT:
		var c: float = 166.0 / 255.0
		VisualServer.set_default_clear_color(Color(c, c, c, 1.0))
	elif tm == Globals.THEME.DARK:
		var c: float = (255.0 - 166.0) / 255.0
		VisualServer.set_default_clear_color(Color(c, c, c, 1.0))

static func LIST_FILES_IN_DIR(path) -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)

	while true:
		var file = dir.get_next()
		if file == "":
			break
		files.append(file)

	dir.list_dir_end()
	return files

static func GET_OFFSET_ON_AXIS(pos: Vector3, direction: int):
	match (direction):
		PLANEID.XM:
			return Vector3(pos.x - 1, pos.y, pos.z)
		PLANEID.XP:
			return Vector3(pos.x + 1, pos.y, pos.z)
		PLANEID.YM:
			return Vector3(pos.x, pos.y - 1, pos.z)
		PLANEID.YP:
			return Vector3(pos.x, pos.y + 1, pos.z)
		PLANEID.ZM:
			return Vector3(pos.x, pos.y, pos.z - 1)
		PLANEID.ZP:
			return Vector3(pos.x, pos.y, pos.z + 1)
		_:
			return null
