extends Node


enum TEXTURETYPE {
	WHITE,
	BLACK
}

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
	TEXTURE
}
const FIRSTTOOL: int = TOOL.SELECT

const TEXTURES: Array = [preload("res://images/editor/white.png"),
						 preload("res://images/editor/black.png")]
