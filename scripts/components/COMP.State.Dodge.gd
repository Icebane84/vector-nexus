"""
[GVRN]
Artifact ID:   COMP.State.Dodge
Description:   Handles directional dodge rolling with state-locking and duration limits.
"""
extends Node

@export_group("Dodge Settings")
var _dodge_speed: float = 18.0
@export var dodge_speed: float:
	get: return _dodge_speed
	set(v):
		_dodge_speed = v
var _dodge_duration: float = 0.4
@export var dodge_duration: float:
	get: return _dodge_duration
	set(v):
		_dodge_duration = v

var _dodge_timer: float = 0.0
var _dodge_direction: Vector3 = Vector3.ZERO

func enter_state(entity: CharacterBody3D, direction_input: Vector3) -> void:
	_dodge_timer = dodge_duration
	
	# DAMP: Explicit fallback if the player dodges without pressing a movement key
	if direction_input == Vector3.ZERO:
		var cam_basis := entity.global_transform.basis
		_dodge_direction = Vector3(-cam_basis.z.x, 0.0, -cam_basis.z.z).normalized()
	else:
		_dodge_direction = direction_input.normalized()
		
	# Snap entity rotation to face the dodge direction immediately
	if _dodge_direction != Vector3.ZERO:
		var target_angle := atan2(-_dodge_direction.x, -_dodge_direction.z)
		entity.rotation.y = target_angle

func update_physics(entity: CharacterBody3D, delta: float) -> String:
	_dodge_timer -= delta
	
	# Lock velocity to the dodge direction
	entity.velocity.x = _dodge_direction.x * dodge_speed
	entity.velocity.z = _dodge_direction.z * dodge_speed
	
	# Apply gravity just in case we dodge off a ledge
	if not entity.is_on_floor():
		var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
		entity.velocity.y -= gravity * delta
		
	entity.move_and_slide()
	
	# Explicit exit once duration expires
	if _dodge_timer <= 0.0:
		return "Idle"
		
	return ""
