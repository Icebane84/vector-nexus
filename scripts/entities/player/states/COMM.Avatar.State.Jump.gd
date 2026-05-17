# [GVRN]
# Artifact ID: COMM.Avatar.State.Jump
# Description: Handling vertical impulse and transition to Fall.
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerJumpState

const PlayerActionBlockState = preload("res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd")

var _jump_force: float = 4.5
@export var jump_force: float:
	get: return _jump_force
	set(v):
		_jump_force = v

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	if anim:
		if anim.has_animation(&"jump"):
			anim.play(&"jump")
		else:
			# Fallback to idle if jump animation is missing
			anim.play(&"idle")
	
	actor.velocity.y = jump_force

func physics_update(delta: float) -> void:
	# Add horizontal control during jump
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if camera:
		var cam_basis: Basis = camera.global_transform.basis
		var direction := (cam_basis.x * input.x - cam_basis.z * input.y).normalized()
		direction.y = 0
		
		# Air control is reduced
		var air_speed: float = 3.0
		actor.velocity.x = move_toward(actor.velocity.x, direction.x * air_speed, delta * 10.0)
		actor.velocity.z = move_toward(actor.velocity.z, direction.z * air_speed, delta * 10.0)
		
		# Rotate visuals to face movement
		if input.length() > 0.1 and actor.visuals:
			var target_rot: float = atan2(-direction.x, -direction.z)
			actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, target_rot, delta * 10.0)


	# Transition to Fall when downward momentum starts
	if actor.velocity.y <= 0:
		state_machine.transition_to(&"Fall")

func exit() -> void:
	super.exit()
