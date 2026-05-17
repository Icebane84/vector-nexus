# [GVRN]
# Artifact ID: COMP.Stats.Stamina
# Description: Manages action economy and physical endurance.
# Author: Architect

extends Node

class_name StaminaComponent

signal stamina_depleted
signal stamina_changed(current: float, max: float)

# SKILL-001: Backing-Field Resilience
var _max_stamina: float = 100.0
@export var max_stamina: float:
	get: return _max_stamina
	set(v): _max_stamina = max(1.0, v); stamina_changed.emit(_current_stamina, _max_stamina)

var _current_stamina: float = 100.0:
	set(v):
		var old: float = _current_stamina
		_current_stamina = clampf(v, 0.0, _max_stamina)
		if _current_stamina != old:
			stamina_changed.emit(_current_stamina, _max_stamina)


var current_stamina: float:
	get: return _current_stamina

var _regen_rate: float = 15.0
@export var regen_rate: float:
	get: return _regen_rate
	set(v): _regen_rate = v

var _regen_pause_time: float = 1.0 # Seconds to wait after consumption
var _regen_timer: float = 0.0

func _process(delta: float) -> void:
	if _regen_timer > 0:
		_regen_timer -= delta
		return

	if _current_stamina < _max_stamina:
		_current_stamina = move_toward(_current_stamina, _max_stamina, _regen_rate * delta)

## Consume stamina. Returns true if successful.
func consume(amount: float) -> bool:
	if _current_stamina < amount:
		return false
	
	_current_stamina -= amount
	_regen_timer = _regen_pause_time # Pause regeneration (User Pref)
	
	if _current_stamina <= 0:
		stamina_depleted.emit()
	
	return true

func is_full() -> bool:
	return _current_stamina >= _max_stamina
