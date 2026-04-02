extends Area3D
class_name HurtboxComponent
signal parry_successful(attacker_pos: Vector3)
@export var health_component: HealthComponent
@export var poise_component: PoiseComponent
@export var team_id: int = 0
var is_invincible: bool = false
var is_parry_window: bool = false
func receive_damage(attack: AttackData) -> void:
	if is_invincible or attack.team_id == team_id: return
	if is_parry_window and attack.can_be_parried:
		parry_successful.emit(attack.attacker_pos)
		return
	if health_component: health_component.receive_damage(attack.damage)
	if poise_component: poise_component.apply_poise_damage(attack.poise_damage)
