# scripts/autoloads/lib/Save.Router.gd
extends RefCounted

## PHOENIX: Save Data Router

static func route_data(tree: SceneTree, node_data: Dictionary) -> void:
	if node_data.has("scene_path"):
		_route_to_new_scene(tree, node_data)
	elif node_data.has("node_path"):
		_route_to_existing_node(tree, node_data)
	else:
		printerr("SaveRouter: Data entry has no 'scene_path' or 'node_path'.")

static func _route_to_new_scene(tree: SceneTree, data: Dictionary) -> void:
	var path: String = data["scene_path"]
	if not ResourceLoader.exists(path):
		printerr("SaveRouter: Scene path not found: ", path)
		return
		
	var instance: Node = (load(path) as PackedScene).instantiate() as Node
	tree.current_scene.add_child(instance)
	
	if instance.has_method("load_data"):
		instance.call("load_data", data)
	else:
		printerr("SaveRouter: New instance lacks load_data().")

static func _route_to_existing_node(tree: SceneTree, data: Dictionary) -> void:
	var path: NodePath = data["node_path"]
	var node: Node = tree.root.get_node_or_null(path)
	
	if node and node.has_method("load_data"):
		node.call("load_data", data)
	else:
		printerr("SaveRouter: Could not find node or load_data() for: ", path)
