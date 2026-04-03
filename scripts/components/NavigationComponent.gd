extends Node
class_name NavigationComponent
@export var nav_agent: NavigationAgent3D
var actor: CharacterBody3D
func setup(p_actor: CharacterBody3D):
	actor = p_actor
	nav_agent.velocity_computed.connect(func(v): actor.velocity = v)
func move_to(target_pos: Vector3):
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished(): return
	var dir = (nav_agent.get_next_path_position() - actor.global_position).normalized()
	nav_agent.set_velocity(dir * nav_agent.max_speed)
