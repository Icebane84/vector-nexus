extends SceneTree

func _init() -> void:
	var path := "C:/Users/Chris/Darksouls Like Starter Kit/Cats-Godot4-Modular-Souls-like-Template-main/enemy/enemy_base_root_motion.tscn"
	var out_path := "res://scratch/findings.txt"
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	if not file:
		print("Failed to open output file!")
		quit(1)
		return
		
	if not FileAccess.file_exists(path):
		file.store_line("Enemy scene not found!")
		file.close()
		quit(1)
		return
		
	var scene = load(path) as PackedScene
	var inst = scene.instantiate()
	
	file.store_line("Enemy Scene Node Transforms:")
	for child in inst.get_children():
		var pos_str = ""
		if child is Node3D:
			pos_str = " position: " + str(child.position) + " rotation: " + str(child.rotation)
		file.store_line("- " + child.name + " [" + child.get_class() + "]" + pos_str)
		
	inst.free()
	file.close()
	quit(0)
