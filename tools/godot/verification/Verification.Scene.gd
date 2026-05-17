# [GVRN]
extends "res://tools/godot/verification/Verification.Base.gd"

## Phase 2: Scene Integrity Suite

func run(context: Dictionary) -> void:
	print("\nPhase 2: Validating Critical Scenes...")
	var scenes: Array = context.get("scenes", [])
	
	for path in scenes:
		_validate_scene(path)

func _validate_scene(path: String) -> void:
	log_info("Validating: " + path)
	if not FileAccess.file_exists(path):
		log_critical("Scene missing: " + path)
		return
		
	var scene: Resource = load(path)
	if scene is PackedScene:
		_test_instantiation(scene as PackedScene, path)
	else:
		log_error("Resource is not a PackedScene: " + path)

func _test_instantiation(scene: PackedScene, path: String) -> void:
	var instance: Node = scene.instantiate() as Node

	if instance:
		log_ok("Scene instantiation successful.")
		instance.free()
	else:
		log_error("Scene instantiation failed: " + path)
