# [GVRN]
# Artifact ID: COMM.Avatar.State.Fall
# Description: Handling downward velocity and landing detection.
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerFallState

const PlayerActionBlockState = preload("res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd")

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	if anim:
		if anim.has_animation(&"fall"):
			anim.play(&"fall")
		else:
			anim.play(&"idle")

func physics_update(delta: float) -> void:
	# Add horizontal control during fall
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if camera:
		var cam_basis: Basis = camera.global_transform.basis
		var direction := (cam_basis.x * input.x - cam_basis.z * input.y).normalized()
		direction.y = 0
		
		var air_speed: float = 3.0
		actor.velocity.x = move_toward(actor.velocity.x, direction.x * air_speed, delta * 10.0)
		actor.velocity.z = move_toward(actor.velocity.z, direction.z * air_speed, delta * 10.0)
		
		if input.length() > 0.1 and actor.visuals:
			var target_rot: float = atan2(-direction.x, -direction.z)
			actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, target_rot, delta * 10.0)


	if actor.is_on_floor():
		if input.length() > 0.1:
			state_machine.transition_to(&"Move")
		else:
			state_machine.transition_to(&"Idle")

func exit() -> void:
	super.exit()
