"""
[GVRN] [COMM] [ENEMY] [STATE]
Artifact ID: COMM.Enemy.State.Hurt
Description: State played when the enemy receives damage. Freezes movement, plays stagger, and returns to chase.
"""
extends State
class_name AIHurtState

var _timer: float = 0.0
const HURT_DURATION: float = 0.4

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
	_timer = 0.0
	if actor:
		actor.velocity = Vector3.ZERO
	
	var voice = _get_voice_sound()
	if voice and actor:
		GameEvents.instance.spatial_sound_requested.emit(voice, actor.global_position, 0.0, 0.1)

	if anim and anim.has_animation(&"hurt"):
		anim.play(&"hurt")

func physics_update(delta: float) -> void:
	_timer += delta
	if _timer >= HURT_DURATION:
		state_machine.transition_to(&"AIChaseState")
