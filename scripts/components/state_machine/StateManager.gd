"""
[GVRN]
Artifact ID: StateManager
Description: Base class for state machines.
"""

extends Node
class_name StateManager

var current_state: State = null

# Dependency Injection passed down from the Orchestrator (e.g., Player.gd)
func setup(initial_state: State) -> void:
	_transition_to(initial_state)

func _physics_process(delta: float) -> void:
	if current_state == null:
		return
		
	# Route the physics tick down into the active state object
	current_state.update(delta)
	
	# Check if the state has requested a transition
	if current_state.next_state != null:
		_transition_to(current_state.next_state)

func _transition_to(new_state: State) -> void:
	# 1. Clean up the old state
	if current_state != null:
		current_state.exit()
		
	# 2. Swap the pointer
	current_state = new_state
	
	# 3. Initialize the new state
	if current_state != null:
		current_state.enter()
