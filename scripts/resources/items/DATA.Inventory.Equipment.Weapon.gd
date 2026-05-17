# [GVRN]
# Artifact ID: DATA.Inventory.Equipment.Weapon
# Description: Data container for equippable weapons.
# Author: Architect

extends ItemData
class_name WeaponData

@export_group("Combat Stats")
var _damage: float = 15.0
@export var damage: float:
	get: return _damage
	set(v):
		_damage = v
var _poise_damage: float = 20.0
@export var poise_damage: float:
	get: return _poise_damage
	set(v):
		_poise_damage = v
var _attack_speed_mult: float = 1.0
@export var attack_speed_mult: float:
	get: return _attack_speed_mult
	set(v):
		_attack_speed_mult = v

@export_group("Visuals")
@export var weapon_model: PackedScene
