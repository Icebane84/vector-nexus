extends Node
class_name HealthComponent
signal health_changed(curr: float, max_v: float)
signal health_depleted
@export var max_health: float = 100.0
var _current_health: float
var current_health: float:
	get: return _current_health
	set(v):
		_current_health = clamp(v, 0.0, max_health)
		health_changed.emit(_current_health, max_health)
		if _current_health <= 0.0: health_depleted.emit()
func _ready(): _current_health = max_health
func receive_damage(amount: float): current_health -= amount
