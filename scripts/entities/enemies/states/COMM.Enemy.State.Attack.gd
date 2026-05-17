"""
[GVRN] [COMM] [ENEMY] [STATE]
Artifact ID: COMM.Enemy.State.Attack
"""
extends State
class_name AIAttackState

func enter(_msg: Dictionary = {}) -> void:
	if anim and anim.has_animation(&"attack"): 
		anim.play(&"attack")

	
	# [Architectural Intent]: Procedural Strike Window
	# Since we lack custom anims, we use a 0.5s "Wind Up" and a 0.2s "Strike".
	get_tree().create_timer(0.5).timeout.connect(_execute_strike)

func _execute_strike() -> void:
	if not actor: return
	
	# 1. Enable Hitbox
	if actor.get("hitbox_component"):
		actor.hitbox_component.set_deferred("monitoring", true)
	
	# 2. Procedural Lunge (using Tween for weight)
	var lunge_dir: Vector3 = -actor.global_transform.basis.z
	if actor.target:
		lunge_dir = (actor.target.global_position - actor.global_position).normalized()
	
	var tween := actor.create_tween()
	tween.tween_property(actor, "velocity", lunge_dir * 12.0, 0.15)
	tween.tween_property(actor, "velocity", Vector3.ZERO, 0.2).set_delay(0.15)
	
	# 3. Teardown
	get_tree().create_timer(0.4).timeout.connect(_on_attack_finished)

func _on_attack_finished() -> void:
	if actor and actor.get("hitbox_component"):
		actor.hitbox_component.set_deferred("monitoring", false)
	
	if state_machine:
		state_machine.transition_to(&"AIChaseState")
