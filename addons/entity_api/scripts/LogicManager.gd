extends Node

# int ID -:- LogicEntity entity
var entity_registry: Dictionary
# string input names -:- array of dictionaries of [entity ID that subscribes to the input -:- FuncRef that takes one dictionary as input]
var inputs: Dictionary
onready var is_active: bool = false

const ON_LOGIC_MANAGER_ACTIVATE = "OnLogicManagerActivate"
const ON_LOGIC_MANAGER_DEACTIVATE = "OnLogicManagerDeactivate"


func add_logic_entity(id: int, ent: Node) -> void:
	entity_registry[id] = ent

func remove_logic_entity(id: int) -> void:
	entity_registry.erase(id)

func add_input(input_name: String, id: int, function_name: String) -> void:
	var func_ref: FuncRef = FuncRef.new()
	func_ref.set_function(function_name)
	func_ref.set_instance(entity_registry[id])
	if !inputs.has(input_name):
		inputs[input_name] = []
	inputs[input_name].append({"id": id, "function": func_ref})

func broadcast(output_name: String, arguments: Dictionary) -> void:
	if inputs.has(output_name):
		for input in inputs[output_name]:
			input["function"].call_func(arguments)

func get_entity_from_id(id: int) -> Node:
	return entity_registry[id]

func set_active(active: bool) -> void:
	is_active = active
	if is_active:
		broadcast(ON_LOGIC_MANAGER_ACTIVATE, {})
	else:
		broadcast(ON_LOGIC_MANAGER_DEACTIVATE, {})

func get_active() -> bool:
	return is_active
