"""
[GVRN] [COMM] [SHARED] [STATE]
Artifact ID: COMM.Shared.State.Stagger
"""
extends State
class_name StaggerState

var _duration: float = 0.5
@export var duration: float:
	get: return _duration
	set(v):
		_duration = v
var _timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	if anim: 
		anim.play(&"stagger")
	
	# Set the atomic timer (SKILL-003 / SKILL-008)
	_timer = duration
	
	# PHOENIX-GVRN: Emit a global signal via the Synapse (SKILL-004)
	if is_instance_valid(actor) and GameEvents.instance:
		GameEvents.instance.character_state_changed.emit(actor, T.CharacterState.STAGGERED)

func physics_update(delta: float) -> void:
	_timer -= delta
	
	if _timer <= 0:
		state_machine.transition_to(&"IdleState")
