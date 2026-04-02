extends Node
class_name PoiseComponent
signal posture_broken
@export var max_poise: float = 100.0
@export var regen_rate: float = 10.0
var _current_poise: float
var is_hyper_armor_active: bool = false
var current_poise: float:
	get: return _current_poise
	set(value):
		if is_hyper_armor_active: return
		_current_poise = clamp(value, 0.0, max_poise)
		if _current_poise <= 0.0:
			posture_broken.emit()
			_current_poise = max_poise
func _ready(): _current_poise = max_poise
func apply_poise_damage(amount: float): current_poise -= amount
