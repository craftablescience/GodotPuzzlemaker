extends Button


func _on_pressed() -> void:
	var vmf = VMF.new(VMF.GAMES.PORTAL_2)
	
	vmf.add_solid(VMF.Block.new(Vector3(0, 0, 0), Vector3(256, 256, 256)).set_material_side(vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A, Vector3.UP).brush)

	var info_player_start = VMF.Entities.Common.InfoPlayerStartEntity.new(vmf)
	
	vmf.write_vmf("user://output.vmf")
	
	get_parent().get_node("Label2").show()
	get_parent().get_node("Button2").show()


func _on_Button2_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
