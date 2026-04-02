extends Node
class_name AttributeComponent
@export var vitality: int = 10
@export var strength: int = 10
func get_damage_multiplier() -> float: return 1.0 + ((strength - 10) * 0.05)
func get_max_hp_bonus() -> float: return (vitality - 10) * 15.0