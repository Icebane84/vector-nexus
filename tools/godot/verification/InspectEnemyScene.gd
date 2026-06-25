extends SceneTree

func _init() -> void:
	var path := "C:/Users/Chris/Darksouls Like Starter Kit/Cats-Godot4-Modular-Souls-like-Template-main/enemy/enemy_base_root_motion.tscn"
	if not FileAccess.file_exists(path):
		print("Enemy scene not found!")
		quit(1)
		return
		
	var scene = load(path) as PackedScene
	var inst = scene.instantiate()
	
	print("Root node class: ", inst.get_class())
	_print_tree(inst, "")
	
	# Find AnimationPlayer
	var ap = _find_anim_player(inst)
	if ap:
		print("\nAnimationPlayer found! Animations list:")
		for anim_name in ap.get_animation_list():
			print("  - ", anim_name)
	else:
		print("\nAnimationPlayer not found!")
		
	inst.free()
	quit(0)

func _print_tree(node: Node, indent: String) -> void:
	var script_str = ""
	if node.get_script():
		script_str = " (Script: " + node.get_script().resource_path.get_file() + ")"
	print(indent, "- ", node.name, " [", node.get_class(), "]", script_str)
	for child in node.get_children():
		_print_tree(child, indent + "  ")

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var res = _find_anim_player(child)
		if res:
			return res
	return null
