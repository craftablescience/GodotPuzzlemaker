extends Button


func _on_pressed() -> void:
	var vmf = VMF.new(VMF.GAMES.PORTAL_2)
	
	vmf.add_solid(VMF.Block.new(Vector3(0, -32, 0), Vector3(512, 64, 512), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
	vmf.add_solid(VMF.Block.new(Vector3(0, 256 + 32, 0), Vector3(512, 64, 512), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
	
	vmf.add_solid(VMF.Block.new(Vector3(0, 128, 256 + 32), Vector3(512, 256, 64), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
	vmf.add_solid(VMF.Block.new(Vector3(0, 128, -256 - 32), Vector3(512, 256, 64), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
	
	vmf.add_solid(VMF.Block.new(Vector3(256 + 32, 128, 0), Vector3(64, 256, 512), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
	vmf.add_solid(VMF.Block.new(Vector3(-256 - 32, 128, 0), Vector3(64, 256, 512), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)
		
	var info_player_start = VMF.Entities.Common.InfoPlayerStartEntity.new(vmf)
	var light             = VMF.Entities.Common.LightEntity.new(vmf, Vector3(0,128,0))
	
	vmf.write_vmf("user://output.vmf")
	
	get_parent().get_node("Label2").show()
	get_parent().get_node("Button2").show()


func _on_Button2_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
