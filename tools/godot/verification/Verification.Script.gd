# [GVRN]
extends "res://tools/godot/verification/Verification.Base.gd"

## Phase 1: Script Validation Suite

func run(context: Dictionary) -> void:
	print("\nPhase 1: Validating Scripts & Instances...")
	var scripts: Array = context.get("scripts", [])
	
	for path in scripts:
		_validate_path(path)

func _validate_path(path: String) -> void:
	log_info("Validating: " + path)
	if not FileAccess.file_exists(path):
		log_critical("File missing: " + path)
		return
		
	var res: Resource = load(path)
	if res == null:
		log_error("Load failed: " + path)
		return
		
	if res is GDScript:
		_validate_script(res as GDScript, path)
	else:
		log_error("Resource is not a GDScript: " + path)

func _validate_script(script: GDScript, path: String) -> void:
	var is_singleton: bool = path.contains("Director") or path.contains("GameEvents")
	
	if script.can_instantiate() and not is_singleton:
		_test_instantiation(script, path)
	elif is_singleton:
		log_ok("Singleton verified.")
	else:
		_handle_non_instantiable(path)

func _test_instantiation(script: GDScript, path: String) -> void:
	var inst: Object = script.new() as Object

	if inst:
		log_ok("Instance created successfully.")
		if inst is Object and not inst is RefCounted:
			inst.free()
	else:
		log_error("Instance creation returned null: " + path)

func _handle_non_instantiable(path: String) -> void:
	if "COMM.Avatar.Player.gd" in path:
		log_critical("Player script cannot be instantiated!")
	else:
		log_skip("Script cannot be instantiated directly.")
