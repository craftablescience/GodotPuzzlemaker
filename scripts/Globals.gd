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
const FIRSTTOOL: int = TOOL.VOXEL

const FILEFORMAT: int = 13

const TEXTUREFALLBACK: String = "white"
