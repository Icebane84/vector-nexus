# [GVRN]
# Artifact ID: COMP.Physics.Health
# Description: Core health management and invincibility handling.
# Author: Architect

extends Node
class_name HealthComponent

signal health_changed(current: float, maximum: float)
signal damaged(amount: float, source: Node)
signal healed(amount: float)
signal died

@export_group("Stats")
var _max_health: float = 100.0
@export var max_health: float:
	get: return _max_health
	set(v):
		_max_health = v

var _invincibility_time: float = 0.5
@export var invincibility_time: float:
	get: return _invincibility_time
	set(v):
		_invincibility_time = v

var _current_health: float = 0.0
var current_health: float:
	get: return _current_health
	set(value):
		var old: float = _current_health
		_current_health = clampf(value, 0.0, max_health)
		if _current_health != old:
			health_changed.emit(_current_health, max_health)


var _invincible: bool = false

func _ready() -> void:
	current_health = max_health

func receive_damage(amount: float, source: Node = null) -> float:
	if _invincible or current_health <= 0.0:
		return 0.0

	var actual: float = minf(amount, current_health)
	current_health -= actual
	damaged.emit(actual, source)

	if current_health <= 0.0:
		died.emit()
	elif invincibility_time > 0.0:
		_start_invincibility()

	return actual

func heal(amount: float) -> float:
	var actual: float = minf(amount, max_health - current_health)
	current_health += actual
	if actual > 0.0:
		healed.emit(actual)
	return actual

func _start_invincibility() -> void:
	_invincible = true
	# PHOENIX-FIX: Ensuring timer is independent of time scale during hit-stops
	# Parameters: time, process_always, process_in_physics, ignore_time_scale
	await get_tree().create_timer(invincibility_time, true, false, true).timeout
	_invincible = false
