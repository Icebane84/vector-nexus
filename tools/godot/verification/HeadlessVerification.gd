extends SceneTree

# PHOENIX ARCHITECT: VERIFICATION ORCHESTRATOR v2.0
# Orchestrates modular verification suites for SKILL-012 compliance.

const BOOTSTRAP_ORDER = [
	"res://scripts/globals/Types.gd",
	"res://scripts/globals/CORE.Kernel.GameEvents.gd",
	"res://scripts/globals/CORE.Kernel.Director.gd",
	"res://scripts/components/COMP.Physics.Health.gd",
	"res://scripts/components/COMP.Stats.Stamina.gd",
	"res://scripts/components/COMP.Stats.Poise.gd",
	"res://scripts/components/COMP.Physics.Hurtbox.gd",
	"res://scripts/components/COMP.Physics.Hitbox.gd",
	"res://scripts/components/COMP.Camera.LockOn.gd",
	"res://scripts/entities/player/COMM.Avatar.PlayerCamera.gd",
	"res://scripts/components/state_machine/FABRIC.Logic.State.gd",
	"res://scripts/components/state_machine/FABRIC.Logic.StateMachine.gd",
	"res://scripts/components/sensors/COMP.AI.Interaction.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
]

const PATTERN_SCRIPTS = [
	"res://scripts/globals/CORE.Kernel.Director.gd",
	"res://scripts/globals/CORE.Kernel.GameEvents.gd",
	"res://scripts/entities/player/COMM.Avatar.Player.gd",
	"res://scripts/entities/player/COMM.Avatar.PlayerCamera.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Idle.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Move.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Attack.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Dodge.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Parry.gd",
	"res://scripts/entities/player/states/COMM.Avatar.State.Stagger.gd"
]

const CRITICAL_SCENES = [
	"res://scenes/entities/Kaelen.tscn",
	"res://scenes/world/TestArena.tscn"
]

func _init() -> void:
	_run_sequence()

func _run_sequence() -> void:
	print("\n--- PHOENIX ARCHITECT: VERIFICATION SEQUENCE START ---")
	
	await _warm_scripts()
	_inject_singletons()
	
	var context: Dictionary = {
		"scripts": PATTERN_SCRIPTS,
		"scenes": CRITICAL_SCENES,
		"player_scene": "res://scenes/entities/Kaelen.tscn",
		"root": root
	}
	
	var suites: Array = [
		load("res://tools/godot/verification/Verification.Script.gd").new(),
		load("res://tools/godot/verification/Verification.Scene.gd").new(),
		load("res://tools/godot/verification/Verification.Stress.gd").new()
	]
	
	var total_success: int = 0
	var total_failure: int = 0
	for suite in suites:
		suite.run(context)
		total_success += suite.success_count
		total_failure += suite.failure_count
		
	_report_and_exit(total_success, total_failure)

func _warm_scripts() -> void:
	print("\nPhase 0: Warming Class Definitions...")
	var remaining: Array = BOOTSTRAP_ORDER.duplicate()
	var retries: int = 5
	while remaining.size() > 0 and retries > 0:
		var failed: Array = []
		for path in remaining:
			if not FileAccess.file_exists(path): continue
			if not load(path): failed.append(path)
		remaining = failed
		retries -= 1
		for i in range(2): await process_frame

func _inject_singletons() -> void:
	print("\nPhase 0.5: Injecting Singletons...")
	var singletons: Dictionary = {
		"_Director": "res://scripts/globals/CORE.Kernel.Director.gd",
		"_GameEvents": "res://scripts/globals/CORE.Kernel.GameEvents.gd"
	}
	for s_name in singletons:
		if not root.has_node(s_name):
			var inst: Node = load(singletons[s_name]).new() as Node
			inst.name = s_name
			root.add_child(inst)

func _report_and_exit(success: int, failure: int) -> void:
	print("\n--- VERIFICATION COMPLETE ---")
	print("Successes: ", success, " | Failures: ", failure)
	if failure > 0:
		print("SYSTEM STATUS: ENTROPY DETECTED. DO NOT COMMIT.")
		quit(1)
	else:
		print("SYSTEM STATUS: ZERO ENTROPY CONFIRMED. CANONIZATION READY.")
		quit(0)
