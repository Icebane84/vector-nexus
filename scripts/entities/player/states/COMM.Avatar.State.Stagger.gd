# [GVRN]
# Artifact ID: COMM.Avatar.State.Stagger
# Description: Hit-stun / Stagger state when poise is broken.
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerStaggerState

var _duration: float = 0.6
@export var duration: float:
	get: return _duration
	set(v):
		_duration = v
var _timer: float = 0.0

var _voice_sounds: Array[AudioStream] = []

func _get_voice_sound() -> AudioStream:
	if _voice_sounds.is_empty():
		for i in range(1, 6):
			var path = "res://audio/SoundFX/voice/voice_hurt_0%d.wav" % i
			var stream = load(path) as AudioStream
			if stream:
				_voice_sounds.append(stream)
	if _voice_sounds.is_empty():
		return null
	return _voice_sounds[randi() % _voice_sounds.size()]

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_timer = duration

	var voice = _get_voice_sound()
	if voice and actor:
		GameEvents.instance.spatial_sound_requested.emit(voice, actor.global_position, 0.0, 0.1)

	if animation_tree and animation_tree.active:
		if actor and actor.has_signal(&"hurt_started"):
			actor.hurt_started.emit()
	else:
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
