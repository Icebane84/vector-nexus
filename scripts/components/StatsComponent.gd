extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node

class_name StatsComponent

signal leveled_up(new_level: int)

signal xp_gained(amount: int, total: int)

@export_group("Base Attributes")

@export var vitality: int = 10 # HP Scaling

@export var strength: int = 10 # Damage Scaling

@export var dexterity: int = 10 # Speed/Stamina Scaling

@export_group("Progression")

@export var level: int = 1

@export var experience: int = 0

@export var xp_requirement_base: int = 100

func get_max_hp() -> float:

	return 100.0 + (vitality * 15.0)

func get_attack_power() -> float:

	return 10.0 + (strength * 2.5)

func add_xp(amount: int) -> void:

	experience += amount

	xp_gained.emit(amount, experience)

	

	var requirement = level * xp_requirement_base

	if experience >= requirement:

		_level_up()

func _level_up() -> void:

	experience -= (level * xp_requirement_base)

	level += 1

	leveled_up.emit(level)

	# Phoenix Resilience: Heal on level up

	if get_parent().has_node("HealthComponent"):

		var hp = get_parent().get_node("HealthComponent") as HealthComponent

		hp.current_health = hp.max_health
