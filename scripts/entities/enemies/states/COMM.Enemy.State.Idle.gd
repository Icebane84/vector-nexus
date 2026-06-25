"""
[GVRN] [COMM] [ENEMY] [STATE]
Artifact ID: COMM.Enemy.State.Idle
Description: Default idle behaviour for AI entities.
             Transitions to Chase when a target is acquired.
"""
extends State
class_name AIIdleState

func enter(_msg: Dictionary = {}) -> void:
	if anim and anim.has_animation(&"idle"):
		anim.play(&"idle")
	if actor:
		actor.velocity = Vector3.ZERO

func physics_update(delta: float) -> void:
	if not actor:
		return

	# Transition to chase state when the enemy has a target
	if actor.get(&"target") != null:
		state_machine.transition_to(&"AIChaseState")
		return

	# Patrol follow logic
	var patrol_target = actor.get(&"patrol_target")
	if patrol_target and is_instance_valid(patrol_target):
		var target_pos: Vector3 = patrol_target.global_position
		var dist = actor.global_position.distance_to(target_pos)
		if dist > 0.5:
			if anim and anim.current_animation != &"move" and anim.has_animation(&"move"):
				anim.play(&"move")
			var direction: Vector3 = (target_pos - actor.global_position).normalized()
			direction.y = 0.0
			var speed = actor.get(&"patrol_speed") if actor.get(&"patrol_speed") else 2.0
			actor.velocity = direction * speed

			# Face the patrol point
			if direction.length_squared() > 0.001:
				var target_angle = atan2(-direction.x, -direction.z)
				actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, target_angle, 10.0 * delta)

			actor.move_and_slide()
		else:
			if anim and anim.current_animation != &"idle" and anim.has_animation(&"idle"):
				anim.play(&"idle")
			actor.velocity = Vector3.ZERO
	else:
		if anim and anim.current_animation != &"idle" and anim.has_animation(&"idle"):
			anim.play(&"idle")
		actor.velocity = Vector3.ZERO
