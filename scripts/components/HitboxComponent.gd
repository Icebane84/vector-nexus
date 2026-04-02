extends Area3D
class_name HitboxComponent
@export var damage: float = 10.0
@export var poise_damage: float = 15.0
@export var team_id: int = 0
func _ready(): area_entered.connect(_on_area_entered)
func _on_area_entered(area: Area3D):
	if area is HurtboxComponent:
		var attack := Director.combat_scratchpad
		attack.damage = damage; attack.poise_damage = poise_damage; attack.team_id = team_id; attack.attacker_pos = global_position
		(area as HurtboxComponent).receive_damage(attack)
		if Director.active_combat_system: Director.active_combat_system.trigger_hit_stop(0.12)
		if Director.vfx_pool: Director.vfx_pool.spawn_vfx(global_position)