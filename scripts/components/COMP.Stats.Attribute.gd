# [GVRN]
# Artifact ID: COMP.Stats.Attribute
# Description: Handles base stats and derives combat modifiers.
# Author: Architect

extends Node

class_name AttributeComponent

var _vitality: int = 10
@export var vitality: int:
	get: return _vitality
	set(v):
		_vitality = v
var _strength: int = 10
@export var strength: int:
	get: return _strength
	set(v):
		_strength = v

func get_damage_multiplier() -> float: return 1.0 + ((strength - 10) * 0.05)

func get_max_hp_bonus() -> float: return (vitality - 10) * 15.0
