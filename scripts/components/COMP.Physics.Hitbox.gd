# [GVRN]
# Artifact ID: COMP.Physics.Hitbox
# Description: Standardized damage application proxy for Area3Ds.
# Version: 2.0 [SOVEREIGN]

extends Area3D
class_name HitboxComponent

# Redundant preloads removed to avoid shadowing global classes


signal hit_registered(pos: Vector3, damage: float, poise_damage: float)

var _damage: float = 10.0
@export var damage: float:
	get: return _damage
	set(v): _damage = max(0.0, v)

var _poise_damage: float = 20.0
@export var poise_damage: float:
	get: return _poise_damage
	set(v): _poise_damage = max(0.0, v)

var _team_id: int = 0
@export var team_id: int:
	get: return _team_id
	set(v): _team_id = v

func _ready() -> void:
	monitoring = false
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func activate_one_shot() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitoring", false)

func _on_area_entered(area: Area3D) -> void:
	if not area is HurtboxComponent: return
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	
	var attack: AttackData = AttackData.new()
	attack.damage = _damage
	attack.poise_damage = _poise_damage
	attack.team_id = team_id
	attack.attacker_pos = global_position
	
	hurtbox.receive_damage(attack)
	hit_registered.emit(global_position, _damage, _poise_damage)
