# [GVRN]
# Artifact ID: COMM.Avatar.State.Stagger
# Description: Hit-stun / Stagger state when poise is broken.
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerStaggerState

const PlayerActionBlockState = preload("res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd")

var _duration: float = 0.6
@export var duration: float:
	get: return _duration
	set(v):
		_duration = v
var _timer: float = 0.0

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_timer = duration
	if anim:
		if anim.has_animation(&"stagger"):
			anim.play(&"stagger")
		else:
			# Fallback if stagger is missing
			if anim.has_animation(&"idle"):
				anim.play(&"idle")

	
	# Clear any buffered inputs on stagger to avoid "Ghost Attacks" after stun
	# This is the inverse of SKILL-010 for negative states.

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	_timer -= delta
	
	if _timer <= 0:
		state_machine.transition_to(&"Idle")
