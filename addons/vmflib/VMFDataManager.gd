extends Node

var ENTITY_COUNT: int = 0
var WORLD_COUNT: int = 0
var SOLID_COUNT: int = 0
var SIDE_COUNT: int = 0
var GROUP_COUNT: int = 0
var VISGROUP_COUNT: int = 0

static func resetValues() -> void:
	VMFDataManager.ENTITY_COUNT = 0
	VMFDataManager.WORLD_COUNT = 0
	VMFDataManager.SOLID_COUNT = 0
	VMFDataManager.SIDE_COUNT = 0
	VMFDataManager.GROUP_COUNT = 0
	VMFDataManager.VISGROUP_COUNT = 0


var DEFAULT_MATERIAL = "TOOLS/TOOLSNODRAW"
