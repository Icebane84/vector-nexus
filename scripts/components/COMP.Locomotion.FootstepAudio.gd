# [GVRN] [UAM-V15]
# Artifact ID:   COMP.Locomotion.FootstepAudio
# Description:   Listens to FootfallSensor signals and routes footstep / cloth-swish
#                audio through the Global Synapse (GameEvents.spatial_sound_requested).
#                No direct AudioStreamPlayer children — audio is spatialised by
#                the engine's Audio Pool (SKILL-002).
#                Phoenix-Pure: SKILL-004 decoupled signaling, SKILL-005 named methods.
# Version:       1.0 [SOVEREIGN]
# Relationships: CONSUMES(COMP.Locomotion.FootfallSensor), SIGNALS(GameEvents)
# Status:        [CANONIZED]
# Source:        Ported from foostep_sound_system.gd (Cats-Godot4-Modular-Souls-like-Template)

extends Node3D
class_name FootstepAudioComponent

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Foot Sensors")
## The FootfallSensor attached to the character's left foot bone.
@export var left_foot: FootfallSensor
## The FootfallSensor attached to the character's right foot bone.
@export var right_foot: FootfallSensor

@export_group("Audio Streams")
## Audio stream played when a foot contacts the ground.
@export var step_sound: AudioStream
## Audio stream played when a foot lifts off (cloth / pants swish).
@export var lift_sound: AudioStream

@export_group("Audio Settings")
## Base volume in decibels for footstep sounds.
@export_range(-40.0, 0.0) var step_volume_db: float = -10.0
## Base volume in decibels for lift sounds.
@export_range(-40.0, 0.0) var lift_volume_db: float = -18.0
## Pitch variance range for naturalness (applied as ± around 1.0).
@export_range(0.0, 0.3) var pitch_variance: float = 0.15

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# SKILL-005: Named method connections only — no lambdas.
	if left_foot:
		left_foot.foot_stepped.connect(_on_foot_stepped)
		left_foot.foot_lifted.connect(_on_foot_lifted)

	if right_foot:
		right_foot.foot_stepped.connect(_on_foot_stepped)
		right_foot.foot_lifted.connect(_on_foot_lifted)

# ---------------------------------------------------------------------------
# Signal Handlers  (SKILL-004: Decoupled Global Signaling)
# ---------------------------------------------------------------------------

func _on_foot_stepped(position: Vector3, _normal: Vector3) -> void:
	if not step_sound:
		return
	var pitch: float = _random_pitch()
	# Route through GameEvents Global Synapse — no direct AudioStreamPlayer needed.
	GameEvents.instance.spatial_sound_requested.emit(step_sound, position, step_volume_db, pitch)
	# Also broadcast the semantic footstep event for other systems (VFX dust, etc.)
	GameEvents.instance.footstep_occurred.emit(position, _normal)

func _on_foot_lifted() -> void:
	if not lift_sound:
		return
	var pitch: float = _random_pitch()
	# Cloth swish plays at the component's own world position (not foot-specific).
	GameEvents.instance.spatial_sound_requested.emit(lift_sound, global_position, lift_volume_db, pitch)
	GameEvents.instance.foot_lifted_occurred.emit()

# ---------------------------------------------------------------------------
# Private — utilities
# ---------------------------------------------------------------------------

func _random_pitch() -> float:
	## Returns a randomised pitch multiplier within ±pitch_variance of 1.0.
	return randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
