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

const FIRSTTOOL: int = TOOL.VOXEL

const FILEFORMAT: int = 13
const FILESETTINGSFORMAT: int = 16

const TEXTUREFALLBACK: String = "white"

static func SET_THEME(tm: int) -> void:
	if tm == Globals.THEME.LIGHT:
		var c: float = 166.0 / 255.0
		VisualServer.set_default_clear_color(Color(c, c, c, 1.0))
	elif tm == Globals.THEME.DARK:
		var c: float = (255.0 - 166.0) / 255.0
		VisualServer.set_default_clear_color(Color(c, c, c, 1.0))
