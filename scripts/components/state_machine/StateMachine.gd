extends Node
class_name StateMachine
@export var initial_state: State
var _current_state: State
var _states: Dictionary = {}
func setup(actor: CharacterBody3D, anim: AnimationPlayer):
	for child in get_children():
		if child is State:
			_states[child.state_id] = child
			child.init_state(actor, anim)
			child.transitioned.connect(on_transition)
	if initial_state: _current_state = initial_state; _current_state.enter()
func _physics_process(delta): if _current_state: _current_state.physics_update(delta)
func on_transition(to: State.ID):
	if not _states.has(to): return
	_current_state.exit()
	_current_state = _states[to]; _current_state.enter()
