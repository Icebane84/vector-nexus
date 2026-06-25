# [GVRN]
# Artifact ID: Tool.Test.PlayerActionSuite
# Description: Headless verification for core player combat and movement states.
extends SceneTree

var player: Player
var test_scene: Node

const ACTION_SUCCESS = 0
const ACTION_FAILURE = 1

func _init() -> void:
	# Per SKILL-023, defer the test run to ensure the full scene tree is ready.
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("--- PHOENIX_LOG: BEGINNING PLAYER ACTION SUITE ---")

	# 1. ARRANGE: Load the test environment and player
	var scene_res = load("res://scenes/world/TestArena.tscn")
	if not scene_res:
		_report_and_quit("Scene 'TestArena.tscn' not found.", ACTION_FAILURE)
		return

	test_scene = scene_res.instantiate()
	root.add_child(test_scene)
	player = test_scene.find_child("Player", true, false) as Player
	if not player:
		_report_and_quit("Player node not found in TestArena.", ACTION_FAILURE)
		return

	# Wait for all _ready() functions to complete.
	await process_frame

	# 2. ACT & ASSERT
	await _test_dodge_and_invincibility()
	await _test_attack_combo_and_stamina()

	_report_and_quit("All player actions verified.", ACTION_SUCCESS)

func _test_dodge_and_invincibility() -> void:
	print("  [TEST] Dodge and Invincibility Frames...")
	assert(player.state_machine.current_state.name == &"Idle", "Initial state should be Idle")

	var initial_stamina: float = player.stamina_component.current_stamina

	# Simulate dodge input
	Input.action_press(&"dodge")
	await process_frame
	Input.action_release(&"dodge")

	assert(player.state_machine.current_state.name == &"Dodge", "Failed to transition to Dodge state.")
	assert(player.hurtbox_component.is_invincible, "Hurtbox should be invincible during dodge.")
	assert(player.stamina_component.current_stamina < initial_stamina, "Dodge did not consume stamina.")
	print("    [PASS] Dodge initiated, stamina consumed, I-frames active.")

	# Wait for dodge to finish
	await get_tree().create_timer(0.5).timeout
	assert(player.state_machine.current_state.name == &"Idle" or player.state_machine.current_state.name == &"Move", "Should return to Idle/Move after dodge.")
	assert(not player.hurtbox_component.is_invincible, "Hurtbox should not be invincible after dodge.")
	print("    [PASS] Dodge completed, I-frames removed.")

func _test_attack_combo_and_stamina() -> void:
	print("  [TEST] Attack Combo and Stamina...")
	var initial_stamina: float = player.stamina_component.current_stamina

	# First attack
	Input.action_press(&"attack")
	await process_frame
	Input.action_release(&"attack")
	assert(player.state_machine.current_state.name == &"Attack", "Failed to transition to Attack state.")
	var stamina_after_1: float = player.stamina_component.current_stamina
	assert(stamina_after_1 < initial_stamina, "First attack did not consume stamina.")
	print("    [PASS] First attack initiated, stamina consumed.")

	# Buffer the second attack
	await get_tree().create_timer(0.2).timeout
	Input.action_press(&"attack")
	await process_frame
	Input.action_release(&"attack")
	await get_tree().create_timer(0.4).timeout # Wait for first attack to finish
	assert(player.state_machine.current_state.name == &"Attack", "Failed to combo into second attack.")
	assert(player.stamina_component.current_stamina < stamina_after_1, "Second attack did not consume stamina.")
	print("    [PASS] Second attack buffered and initiated.")

func _report_and_quit(message: String, code: int) -> void:
	print(message)
	get_tree().quit(code)