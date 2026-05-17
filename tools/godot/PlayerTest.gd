# [GVRN]
# PlayerTest.gd
# Purpose: Headless-safe unit test for COMM.Avatar.Player.gd
extends "res://tools/godot/BaseComponentTest.gd"

func _initialize() -> void:
	# Use the SceneTree's root
	var root: Node = self.root
	print("--- PHOENIX_LOG: BEGINNING PLAYER TDD (RED PHASE) ---")
	
	# 0. Headless Bootstrap: Register class_names manually
	var dependencies: Array[String] = [
		"res://scripts/components/state_machine/FABRIC.Logic.StateMachine.gd",
		"res://scripts/components/COMP.Physics.Health.gd",
		"res://scripts/components/COMP.Stats.Stamina.gd",
		"res://scripts/components/COMP.Physics.Hitbox.gd",
		"res://scripts/components/COMP.Physics.Hurtbox.gd",
		"res://scripts/components/COMP.Stats.Poise.gd",
		"res://scripts/entities/player/COMM.Avatar.PlayerCamera.gd",
		"res://scripts/globals/CORE.Kernel.Director.gd",
        "res://scripts/globals/CORE.Kernel.GameEvents.gd"
	]
	for path in dependencies:
		var script: GDScript = load(path) as GDScript
		if script:
			print("PHOENIX_LOG: Warmed script -> ", path.get_file())
		else:
			print("PHOENIX_LOG: [!] FAILED TO WARM -> ", path)

	print("PHOENIX_LOG: Initializing Player Test...")
	# Warming Singletons (Use explicit load to bypass parse-time global resolution)
	var director: Node = load("res://scripts/globals/CORE.Kernel.Director.gd").instance as Node
	var game_events: Node = load("res://scripts/globals/CORE.Kernel.GameEvents.gd").instance as Node
	
	# 1. Arrange: Create Player and Mock Dependencies
	var player_script: GDScript = load("res://scripts/entities/player/COMM.Avatar.Player.gd") as GDScript
	var player: CharacterBody3D = player_script.new() as CharacterBody3D
	
	var state_machine: Node = load("res://scripts/components/state_machine/FABRIC.Logic.StateMachine.gd").new() as Node
	var anim_tree: AnimationTree = AnimationTree.new()
	var anim_player: AnimationPlayer = AnimationPlayer.new()
	
	var health: Node = load("res://scripts/components/COMP.Physics.Health.gd").new() as Node
	var stamina: Node = load("res://scripts/components/COMP.Stats.Stamina.gd").new() as Node
	var poise: Node = load("res://scripts/components/COMP.Stats.Poise.gd").new() as Node
	var hurtbox: Node = load("res://scripts/components/COMP.Physics.Hurtbox.gd").new() as Node
	var hitbox: Node = load("res://scripts/components/COMP.Physics.Hitbox.gd").new() as Node
	
	# Assign Exports
	player.state_machine = state_machine
	player.animation_tree = anim_tree
	player.animation_player = anim_player
	player.health_component = health
	player.stamina_component = stamina
	player.poise_component = poise
	player.hurtbox_component = hurtbox
	player.hitbox_component = hitbox
	
	# Create a mock state to verify dependency injection propagation
	var state_script: GDScript = load("res://scripts/components/state_machine/FABRIC.Logic.State.gd") as GDScript
	var mock_state: Node = state_script.new() as Node
	mock_state.name = "MockState"
	state_machine.add_child(mock_state)
	player.add_child(state_machine)

	# 2. Act: Trigger initialization by adding the node to the scene tree
	print("  [ACTION] Initializing Player Orchestrator...")
	root.add_child(player)
	# Wait for the frame to ensure _ready() and internal wiring completes
	await process_frame
	
	var success := true
	
	# 3. Assert: Director Registration
	director = load("res://scripts/globals/CORE.Kernel.Director.gd").instance
	success = assert_eq(director.player, player, "test_director_registration: Player registered to Director.instance.") and success
		
	# 4. Assert: Dependency Weaving (SKILL-009 Fix Verification)
	success = assert_true(mock_state.actor == player and mock_state.anim == anim_player, "test_dependency_weaving: State dependencies injected downwards correctly.") and success

	# 5. Assert: Internal Signal Routing
	success = assert_connected(poise.posture_broken, player, "_on_posture_broken", "test_poise_connection: Posture broken signal successfully routed to Orchestrator.") and success

	if success:
		print("--- PHOENIX_LOG: PLAYER TDD PASSED (PHOENIX-GREEN) ---")
		quit(0)
	else:
		print("--- PHOENIX_LOG: PLAYER TDD FAILED (PHOENIX-RED) ---")
		quit(1)
