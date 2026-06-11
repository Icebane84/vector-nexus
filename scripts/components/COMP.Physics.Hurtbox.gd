# [GVRN]
# Artifact ID: COMP.Physics.Hurtbox
# Description: Centralized damage reception logic for living entities.
# Version: 2.0 [SOVEREIGN]

extends Area3D
class_name HurtboxComponent

# Redundant preloads removed to avoid shadowing global classes (SKILL-007)


signal hit_received(attack: AttackData)
signal parry_successful(attacker_pos: Vector3)

@export var health_component: HealthComponent
@export var poise_component: PoiseComponent
var _team_id: int = 0
@export var team_id: int:
	get: return _team_id
	set(v): _team_id = v

var _is_invincible: bool = false
@export var is_invincible: bool:
	get: return _is_invincible
	set(v): _is_invincible = v

var _is_parry_window: bool = false
@export var is_parry_window: bool:
	get: return _is_parry_window
	set(v): _is_parry_window = v

func receive_damage(attack: AttackData) -> void:
	if attack.team_id == team_id: return
	if _is_invincible: return

	if _is_parry_window and attack.can_be_parried:
		_handle_parry(attack)
		return

	if owner and "guarding" in owner and owner.guarding:
		if owner.has_signal(&"block_started"):
			owner.block_started.emit()
		
		# Reduce damage by 80% and poise damage by 50%
		var blocked_damage := attack.damage * 0.2
		var blocked_poise := attack.poise_damage * 0.5
		
		var blocked_attack = attack.duplicate() as AttackData
		blocked_attack.damage = blocked_damage
		blocked_attack.poise_damage = blocked_poise
		
		_apply_impact(blocked_attack)
		hit_received.emit(blocked_attack)
		return

	_apply_impact(attack)
	hit_received.emit(attack)

func _handle_parry(attack: AttackData) -> void:
	parry_successful.emit(attack.attacker_pos)

func _apply_impact(attack: AttackData) -> void:
	if health_component:
		health_component.receive_damage(attack.damage)
	
	if poise_component:
		poise_component.apply_poise_damage(attack.poise_damage)
