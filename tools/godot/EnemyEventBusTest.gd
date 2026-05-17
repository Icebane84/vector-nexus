# [GVRN]
# EnemyEventBusTest.gd
# Purpose: Headless-safe unit test for Enemy Universal Event Bus broadcasting.
extends SceneTree

var _received_state: T.CombatState = T.CombatState.IDLE
var _event_received: bool = false

func _init() -> void:
	print("--- PHOENIX_LOG: BEGINNING ENEMY EVENT BUS TDD (RED PHASE) ---")

	# 1. Arrange: Create mock EnemyBase and StateMachine dependencies
	var enemy := EnemyBase.new()
	var state_machine := StateMachine.new()
	
	var chase_state := AIChaseState.new()
	chase_state.name = "AIChaseState"
	
	state_machine.add_child(chase_state)
	enemy.state_machine = state_machine
	enemy.add_child(state_machine)

	# Connect to the global GameEvents bus
	GameEvents.instance.combat_state_changed.connect(_on_combat_state_changed)

	print("  [ACTION] Initializing Enemy Orchestrator...")
	# Trigger internal initialization by adding to the tree
	root.add_child(enemy)
	# Wait for the frame to ensure _ready() and internal wiring completes
	await process_frame

	# 2. Act: Fake a local state transition from Idle to Chase
	print("  [ACTION] Emitting state_changed(&\"AIIdleState\", &\"AIChaseState\")...")
	state_machine.state_changed.emit(&"AIIdleState", &"AIChaseState")

	# 3. Assert: Did the Orchestrator map this to the Universal Enum and broadcast it?
	if _event_received and _received_state == T.CombatState.CHASE:
		print("  [PASS] test_event_routing: state_changed properly routed to GameEvents with T.CombatState.CHASE.")
	else:
		print("  [FAIL] test_event_routing: Event not routed correctly.")

	print("--- PHOENIX_LOG: TDD COMPLETE ---")
	quit(0)

func _on_combat_state_changed(_actor: Node3D, new_state: T.CombatState) -> void:
	_event_received = true
	_received_state = new_state
