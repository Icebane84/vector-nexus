# [GVRN]
# Artifact ID: DATA.AI.BossPhase
# Description: Data container for defining boss phase transitions.
# Author: Architect

extends Resource
class_name BossPhaseData

var _hp_threshold: float = 0.5
@export var hp_threshold: float:
	get: return _hp_threshold
	set(v):
		_hp_threshold = v
@export var phase_animation: StringName = &"phase_transition"
var _damage_mult: float = 1.5
@export var damage_mult: float:
	get: return _damage_mult
	set(v):
		_damage_mult = v
var _speed_mult: float = 1.3
@export var speed_mult: float:
	get: return _speed_mult
	set(v):
		_speed_mult = v
