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

const MOUSE_SENSITIVITY: float = 0.02
const MOBILE_SENSITIVITY: float = 32.0
const MOVEMENT_SENSITIVITY: float = 1.0

const FIRSTTOOL: int = TOOL.VOXEL

const FILEFORMAT: int = 17
const FILESETTINGSFORMAT: int = 16

const TEXTUREFALLBACK: String = "builtin:white"

var Discord = preload("res://gdnative/libdiscord.gdns")
var DISCORD = Discord.new()

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
