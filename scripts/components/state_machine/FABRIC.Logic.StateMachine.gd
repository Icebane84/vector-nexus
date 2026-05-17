# [GVRN]
# Artifact ID: FABRIC.Logic.StateMachine
# Description: Standard hierarchical state machine pattern.
# Version: [SOVEREIGN]
# Author: Architect

extends Node
class_name StateMachine


# const State = preload("res://scripts/components/state_machine/FABRIC.Logic.State.gd") # Shadowing global class State


signal state_changed(from_state: StringName, to_state: StringName)

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# PHOENIX-GVRN: Automatic Recursive Registration
	_register_states(self)

	# Delay start to ensure actor/animation pointers are valid in parent
	await get_tree().process_frame

	if not initial_state and get_child_count() > 0:
		for child in get_children():
			if child is State:
				initial_state = child
				break
	
	if initial_state:
		print("[StateMachine] Starting with state: ", initial_state.name)
		current_state = initial_state
		current_state.process_mode = Node.PROCESS_MODE_INHERIT
		current_state.enter()
	else:
		push_warning("[StateMachine] No initial state found for " + get_parent().name)

func _register_states(parent: Node) -> void:
	for child in parent.get_children():
		if child is State:
			var s_name := StringName(child.name)
			states[s_name] = child
			child.state_machine = self
			child.process_mode = Node.PROCESS_MODE_DISABLED
			print("[StateMachine] Registered state: ", s_name)
			# Recurse for nested states (HSM Support)
			_register_states(child)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func transition_to(state_name: StringName, msg: Dictionary = {}) -> void:
	if not states.has(state_name):
		# PHOENIX-LOG: Resilient Error Handling
		push_error("State '%s' not found in %s" % [state_name, get_parent().name])
		return

	var previous_state := current_state
	if previous_state:
		previous_state.exit()
		previous_state.process_mode = Node.PROCESS_MODE_DISABLED

	current_state = states[state_name]
	current_state.process_mode = Node.PROCESS_MODE_INHERIT
	current_state.enter(msg)

	print("[StateMachine] Transitioned to: ", current_state.name)
	state_changed.emit(previous_state.name if previous_state else &"", current_state.name)
