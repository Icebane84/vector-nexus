# [GVRN]
# Artifact ID: COMM.Avatar.State.Parry
# Description: Standardized parry animation state with frame-locked recovery.
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerParryState


var _duration: float = 0.3
@export var duration: float:
	get: return _duration
	set(v):
		_duration = v

var _timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_timer = duration
	
	if animation_tree and animation_tree.active:
		if actor and actor.has_signal(&"parry_started"):
			actor.parry_started.emit()
	else:
		if anim:
			if anim.has_animation(&"parry"):
				anim.play(&"parry")
			else:
				push_warning("Parry animation 'parry' not found. Using fallback.")
				if anim.has_animation(&"idle"):
					anim.play(&"idle")

	
	# SKILL-010: Buffer check
	if Input.is_action_just_pressed(&"attack"):
		state_machine.transition_to(&"Attack")
		return
		
	if hurtbox:
		hurtbox.is_parry_window = true

func exit() -> void:
	super.exit()
	if hurtbox:
		hurtbox.is_parry_window = false

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	_timer -= delta
	
	if _timer <= 0:
		state_machine.transition_to(&"Idle")
