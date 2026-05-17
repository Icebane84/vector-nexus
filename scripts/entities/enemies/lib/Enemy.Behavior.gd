# scripts/entities/enemies/lib/Enemy.Behavior.gd
extends RefCounted

## PHOENIX: Enemy Behavior Logic Library
## Offloads complex navigation and state transition logic for enemies.

static func get_random_wander_target(origin: Vector3, radius: float) -> Vector3:
	var rand_dir := Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
	return origin + (rand_dir * randf_range(1.0, radius))

static func check_for_target(actor: Node, state_machine: Node, transition_name: StringName = &"AIChaseState") -> bool:
	if actor and actor.get("target") != null:
		state_machine.transition_to(transition_name)
		return true
	return false

static func play_ai_animation(anim: AnimationPlayer, anim_name: StringName) -> void:
	if anim and anim.has_animation(anim_name):
		anim.play(anim_name)
