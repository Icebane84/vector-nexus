"""
[GVRN]
Artifact ID:   COMP.State.Jump
Description:   Modular state for handling entity jumping. Strictly decoupled from input.
"""
extends Node
# Assumes usage inside your existing StateMachine orchestrator

var _jump_impulse: float = 14.0
@export var jump_impulse: float:
	get: return _jump_impulse
	set(v):
		_jump_impulse = v
var _gravity_multiplier: float = 1.5
@export var gravity_multiplier: float:
	get: return _gravity_multiplier
	set(v):
		_gravity_multiplier = v

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func enter_state(entity: CharacterBody3D) -> void:
	if entity.is_on_floor():
		entity.velocity.y = jump_impulse

func update_physics(entity: CharacterBody3D, delta: float) -> String:
	# Apply custom gravity curve for a snappy, heavy jump
	entity.velocity.y -= (_gravity * gravity_multiplier) * delta
	entity.move_and_slide()
	
	# DAMP: Explicit exit conditions
	if entity.is_on_floor():
		if entity.velocity.length_squared() > 0.1:
			return "Move"
		return "Idle"
		
	if entity.velocity.y < 0.0:
		return "Fall"
		
	# Returning an empty string (or predefined constant) tells the orchestrator 
	# to keep running the current state
	return ""
