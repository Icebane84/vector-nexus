# scripts/systems/manifestation_system.gd
# @nexus GUCA.AOATH.MANIFESTATION_BRIDGE
class_name ManifestationSystem
extends RefCounted

var timer := 0.0

# Active flags/values for controller/render queries
var active_input_delay := false
var current_distortion := 0.0

func update(delta: float, instability: float) -> void:
	timer -= delta
	
	# Keep scaling distortion based on instability rating (above 25% instability)
	current_distortion = lerp(current_distortion, clamp((instability - 25.0) / 75.0, 0.0, 1.0) * 0.4, delta * 2.0)

	if timer <= 0:
		trigger(instability)
		timer = get_interval(instability)

func get_interval(instability: float) -> float:
	if instability < 25:
		return 999.0
	elif instability < 50:
		return 8.0
	elif instability < 80:
		return 5.0
	else:
		return 2.5

func trigger(instability: float) -> void:
	var roll = randf()
	active_input_delay = false # Default reset unless explicitly triggered

	if instability < 50:
		if roll < 0.5:
			SeltLogger.log_event("WHISPER", instability, "Whispering static begins to resonate in the player's mind.")
		else:
			SeltLogger.log_event("UI_FLICKER", instability, "Minor interface sync flickering detected.")
	elif instability < 80:
		if roll < 0.3:
			SeltLogger.log_event("FAKE_DAMAGE", instability, "Ghostly damage metrics generated on player screen.")
		elif roll < 0.6:
			active_input_delay = true
			SeltLogger.log_event("INPUT_DELAY", instability, "Instability spikes: input delays active for next phase.")
		else:
			SeltLogger.log_event("MISREAD", instability, "Enemy vectors appear shifted due to cognitive slip.")
	else:
		if roll < 0.3:
			SeltLogger.log_event("FORCED_ATTACK", instability, "Neurolink disruption forces avatar reflex action!")
		elif roll < 0.6:
			SeltLogger.log_event("SHADOW_ECHO", instability, "Shadow echo strike echoes past position.")
		else:
			SeltLogger.log_event("DISTORTION", instability, "CRITICAL: Full reality distortion triggered.")
