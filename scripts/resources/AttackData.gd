extends Resource
class_name AttackData
@export var damage: float = 10.0
@export var poise_damage: float = 20.0
@export var team_id: int = 0 # 0: Player, 1: Enemy
@export var attacker_pos: Vector3
@export var can_be_parried: bool = true