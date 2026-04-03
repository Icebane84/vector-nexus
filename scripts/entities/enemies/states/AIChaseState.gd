extends State
@export var nav_comp: NavigationComponent
func physics_update(_d):
	var enemy = actor as EnemyBase; if not enemy.target: return
	nav_comp.move_to(enemy.target.global_position)
	if actor.global_position.distance_to(enemy.target.global_position) < 2.0: transitioned.emit(ID.ATTACK)
