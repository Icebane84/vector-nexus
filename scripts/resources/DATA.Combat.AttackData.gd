# [GVRN]
# Artifact ID: DATA.Combat.AttackData
# Description: Data container for defining attacks and their properties.
# Author: Architect

extends Resource
class_name AttackData

var _damage: float = 10.0
@export var damage: float:
	get: return _damage
	set(v):
		_damage = v
var _poise_damage: float = 20.0
@export var poise_damage: float:
	get: return _poise_damage
	set(v):
		_poise_damage = v
var _team_id: int = 0 # 0: Player, 1: Enemy
@export var team_id: int:
	get: return _team_id
	set(v):
		_team_id = v
@export var attacker_pos: Vector3
@export var can_be_parried: bool = true
