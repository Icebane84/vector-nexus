# res://scripts/resources/items/WeaponData.gd
extends ItemData
class_name WeaponData

@export_group("Combat Stats")
@export var damage: float = 15.0
@export var poise_damage: float = 20.0
@export var attack_speed_mult: float = 1.0

@export_group("Visuals")
@export var weapon_model: PackedScene
