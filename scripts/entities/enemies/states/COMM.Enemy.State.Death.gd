"""
[GVRN] [COMM] [ENEMY] [STATE]
Artifact ID: COMM.Enemy.State.Death
Description: Handles enemy entity death, disabling collisions, playing the death animation, and cleaning up.
"""
extends State
class_name AIDeathState

func enter(_msg: Dictionary = {}) -> void:
	if actor:
		actor.velocity = Vector3.ZERO
		# Disable hurtbox to prevent further hits
		if actor.get("hurtbox_component"):
			actor.hurtbox_component.set_deferred("monitoring", false)
			actor.hurtbox_component.set_deferred("monitorable", false)
		# Disable hitbox to stop any active attacks
		if actor.get("hitbox_component"):
			actor.hitbox_component.set_deferred("monitoring", false)
			actor.hitbox_component.set_deferred("monitorable", false)

	if anim:
		if anim.has_animation(&"death"):
			if not anim.animation_finished.is_connected(_on_animation_finished):
				anim.animation_finished.connect(_on_animation_finished)
			anim.play(&"death")
		else:
			# Fallback if death animation is missing
			get_tree().create_timer(1.5).timeout.connect(_on_death_timeout)
	else:
		_do_teardown()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"death":
		if anim.animation_finished.is_connected(_on_animation_finished):
			anim.animation_finished.disconnect(_on_animation_finished)
		_do_teardown()

func _on_death_timeout() -> void:
	_do_teardown()

func _do_teardown() -> void:
	if actor:
		actor.queue_free()
