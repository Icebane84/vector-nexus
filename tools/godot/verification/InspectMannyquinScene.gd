extends SceneTree

func _init() -> void:
	var path = "res://assets/Models/mannyquin.glb"
	if not FileAccess.file_exists(path):
		print("ERROR: mannyquin.glb not found!")
		quit(1)
		return
		
	var scene = load(path) as PackedScene
	if not scene:
		print("ERROR: Failed to load mannyquin.glb!")
		quit(1)
		return
		
	var inst = scene.instantiate()
	print("mannyquin.glb root node: ", inst.name)
	_print_children(inst, "  ")
	quit(0)

func _print_children(node: Node, indent: String) -> void:
	for child in node.get_children():
		print(indent, child.name, " (", child.get_class(), ")")
		_print_children(child, indent + "  ")
