extends Panel


var input_logic_id: int
var output_logic_id: int


func set_inputs(inputs: Array) -> void:
	$InputContainer/InputSelection.clear()
	if len(inputs) == 0:
		$InputContainer/InputSelection.add_item("...")
	else:
		for input in inputs:
			$InputContainer/InputSelection.add_item(input)

func set_outputs(outputs: Array) -> void:
	$OutputContainer/OutputSelection.clear()
	if len(outputs) == 0:
		$OutputContainer/OutputSelection.add_item("...")
	else:
		for output in outputs:
			$OutputContainer/OutputSelection.add_item(output)

func set_input_id(id: int) -> void:
	self.self_modulate = Color.white
	input_logic_id = id
	$InputName.text = str(id)

func set_output_id(id: int) -> void:
	output_logic_id = id
	$OutputName.text = str(id)

func _on_InputName_pressed() -> void:
	get_parent().set_input_listener(self)

func _on_Delete_pressed() -> void:
	get_parent().remove_connection(self)
