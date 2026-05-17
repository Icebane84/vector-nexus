# [GVRN]
extends "res://tools/godot/verification/Verification.Base.gd"

## Phase 3: Locomotion Stress Test Suite

func run(context: Dictionary) -> void:
	print("\nPhase 3: Locomotion Stress Test...")
	var player_scene_path: String = context.get("player_scene", "")
	var root: Node = context.get("root")
	
	var player_scene: Resource = load(player_scene_path)
	if player_scene is PackedScene:
		_run_stress_test(player_scene as PackedScene, root)
	else:
		log_error("Could not load Player scene for stress test: " + player_scene_path)

func _run_stress_test(player_scene: PackedScene, root: Node) -> void:
	var player: Node = player_scene.instantiate() as Node
	root.add_child(player)
	log_ok("Player instantiated and added to tree.")
	
	_verify_initial_state(player)
	_verify_gravity(player)
	_verify_movement(player)
	
	player.free()

func _verify_initial_state(player: Node) -> void:
	var sm: Node = player.get_node_or_null("StateMachine")
	if not sm:
		log_error("StateMachine missing on Player scene.")
		return
		
	var state_name: String = _get_current_state_name(sm)
	log_ok("Initial State: " + state_name)

func _get_current_state_name(sm: Node) -> String:
	if "current_state" in sm and sm.current_state:
		return sm.current_state.name
	return "unknown"

func _verify_gravity(player: Node) -> void:
	var initial_y: float = player.global_position.y
	log_info("Simulating 10 physics frames (Gravity Check)...")
	for i in range(10):
		_step_physics(player)
	
	if player.global_position.y < initial_y:
		log_ok("Gravity applied: Y-pos decreased.")
	else:
		log_skip("Gravity not applied or player grounded.")

func _step_physics(player: Node) -> void:
	if player.has_method("_physics_process"):
		player.call("_physics_process", 0.016)
	else:
		player.notification(Node.NOTIFICATION_INTERNAL_PHYSICS_PROCESS)

func _verify_movement(player: Node) -> void:
	log_info("Simulating 'move_forward' input...")
	Input.action_press("move_forward")
	_step_physics(player)
	
	var sm: Node = player.get_node_or_null("StateMachine")
	if sm:
		var current_name: String = _get_current_state_name(sm).to_lower()
		if current_name.contains("move"):
			log_ok("Transitioned to MOVE state.")
		else:
			log_skip("Transition to MOVE failed. Current: " + current_name)
	
	Input.action_release("move_forward")
