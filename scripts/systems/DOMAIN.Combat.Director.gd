# [GVRN]
# Artifact ID:   DOMAIN.Combat.Director
# Description:   High-level combat orchestrator. Handles encounters and cinematic feedback.
#                Sovereign Bridge: Communicates purely via GameEvents synapse.

extends Node
class_name CombatDirector

const ImpactLib = preload("res://scripts/components/lib/Combat.Impact.gd")

func _ready() -> void:
	# Reactive Decoupling: Listen to Global Synapse for impact events
	if GameEvents.instance:
		GameEvents.instance.impact_occurred.connect(trigger_impact_feedback)
		GameEvents.instance.parry_occurred.connect(trigger_parry_hitstop)

## --- Cinematic Impact Flow (SKILL-012 Compliant) ---

func trigger_hit_stop(duration: float, time_scale: float = 0.05) -> void:
	Engine.time_scale = time_scale
	var timer := get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(_reset_time_scale)

func trigger_parry_hitstop() -> void:
	trigger_hit_stop(ImpactLib.HITSTOP_PARRY, ImpactLib.TIMESCALE_FREEZE)

func trigger_impact_feedback(pos: Vector3, damage: float, poise_damage: float) -> void:
	# 1. Hitstop logic
	var duration: float = ImpactLib.get_hitstop_duration(damage, poise_damage)
	trigger_hit_stop(duration)
	
	# 2. Visuals - Handled by VFXSystem listening to impact_occurred
	
	# 3. Audio - Request via Global Synapse
	_play_impact_sfx(pos, damage)

func _play_impact_sfx(pos: Vector3, _damage: float) -> void:
	# Example: Request a hit sound
	# GameEvents.instance.spatial_sound_requested.emit(hit_sound_stream, pos, 0.0, 0.1)
	pass

func _reset_time_scale() -> void:
	Engine.time_scale = 1.0
