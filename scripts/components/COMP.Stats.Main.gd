# [GVRN]
# Artifact ID: COMP.Stats.Main
# Description: Centralized statistics hub handling level, XP, and attribute bonuses.
# Author: Architect

extends Node

class_name StatsComponent

signal leveled_up(new_level: int)
signal xp_gained(amount: int, total: int)

@export_group("Base Attributes")
var _vitality: int = 10
@export var vitality: int:
	get: return _vitality
	set(v):
		_vitality = v
var _strength: int = 10
@export var strength: int:
	get: return _strength
	set(v):
		_strength = v
var _dexterity: int = 10
@export var dexterity: int:
	get: return _dexterity
	set(v):
		_dexterity = v
@export var health_component: HealthComponent

@export_group("Progression")
var _level: int = 1
@export var level: int:
	get: return _level
	set(v):
		_level = v
var _experience: int = 0
@export var experience: int:
	get: return _experience
	set(v):
		_experience = v
var _xp_requirement_base: int = 100
@export var xp_requirement_base: int:
	get: return _xp_requirement_base
	set(v):
		_xp_requirement_base = v

func get_max_hp() -> float:
	return 100.0 + (vitality * 15.0)

func get_attack_power() -> float:
	return 10.0 + (strength * 2.5)

func add_xp(amount: int) -> void:
	experience += amount
	xp_gained.emit(amount, experience)

	var requirement: int = level * xp_requirement_base

	if experience >= requirement:
		_level_up()

func _level_up() -> void:
	experience -= (level * xp_requirement_base)
	level += 1
	leveled_up.emit(level)

	if health_component:
		health_component.current_health = health_component.max_health
