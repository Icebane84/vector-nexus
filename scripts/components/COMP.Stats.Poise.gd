# [GVRN]
# Artifact ID: COMP.Stats.Poise
# Description: Manages stability and stagger thresholds.
# Author: Architect

extends Node

class_name PoiseComponent

signal posture_broken

var _max_poise: float = 100.0
@export var max_poise: float:
	get: return _max_poise
	set(v):
		_max_poise = v
var _current_poise: float
var is_hyper_armor_active: bool = false
var current_poise: float:
	get: return _current_poise
	set(v):
		if is_hyper_armor_active: return
		_current_poise = clamp(v, 0.0, max_poise)
		if _current_poise <= 0.0: 
			posture_broken.emit()
			_current_poise = max_poise
func _ready() -> void: _current_poise = max_poise

func apply_poise_damage(amount: float) -> void:
	self.current_poise -= amount
