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

func physics_update(_delta: float) -> void:
	if not actor:
		return

	# Transition to chase state when the enemy has a target
	if actor.get(&"target") != null:
		state_machine.transition_to(&"AIChaseState")
