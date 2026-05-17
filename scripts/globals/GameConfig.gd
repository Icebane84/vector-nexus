# GameConfig.gd
extends Resource
class_name GameConfig

@export_group("Difficulty Multipliers")
var _enemy_damage_mod: float = 1.0
@export var enemy_damage_mod: float:
	get: return _enemy_damage_mod
	set(v):
		_enemy_damage_mod = v
var _enemy_health_mod: float = 1.0
@export var enemy_health_mod: float:
	get: return _enemy_health_mod
	set(v):
		_enemy_health_mod = v
var _player_stamina_regen: float = 10.0
@export var player_stamina_regen: float:
	get: return _player_stamina_regen
	set(v):
		_player_stamina_regen = v

@export_group("World Settings")
var _shadow_intensity: float = 0.8
@export var shadow_intensity: float:
	get: return _shadow_intensity
	set(v):
		_shadow_intensity = v
var _oakhaven_visibility: float = 50.0
@export var oakhaven_visibility: float:
	get: return _oakhaven_visibility
	set(v):
		_oakhaven_visibility = v
