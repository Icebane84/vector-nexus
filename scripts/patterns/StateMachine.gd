"""
[GVRN]
Artifact ID: CORE.Pattern.StateMachine
Description: Standard hierarchical state machine pattern.
Version: [SOVEREIGN]
Author: Architect
"""
extends Node
class_name PatternStateMachine

## PHOENIX ARCHITECT: SKILL-008 ALIGNMENT
## The "Phoenix-Pure" State Machine reference pattern.

signal state_changed(from_state: StringName, to_state: StringName)

@export var initial_state: PatternState

var current_state: PatternState
var states: Dictionary = {}

func _ready() -> void:
	_register_states(self)

	if initial_state:
		current_state = initial_state
		current_state.process_mode = Node.PROCESS_MODE_INHERIT
		current_state.enter()

func _register_states(parent: Node) -> void:
	for child in parent.get_children():
		if child is PatternState:
			states[child.name] = child
			child.state_machine = self
			child.process_mode = Node.PROCESS_MODE_DISABLED
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
		push_error("State '%s' not found" % state_name)
		return

	var previous_state := current_state
	if previous_state:
		previous_state.exit()
		previous_state.process_mode = Node.PROCESS_MODE_DISABLED

	current_state = states[state_name]
	current_state.process_mode = Node.PROCESS_MODE_INHERIT
	current_state.enter(msg)

	state_changed.emit(previous_state.name if previous_state else &"", current_state.name)
