# [GVRN]
# Artifact ID: COMP.AI.Navigation
# Description: Standard pathfinding interface using NavigationAgent3D.
# Author: Architect

extends Node

class_name NavigationComponent

@export var nav_agent: NavigationAgent3D
var actor: CharacterBody3D

func setup(p_actor: CharacterBody3D) -> void:
	actor = p_actor
	if not nav_agent: nav_agent = get_node_or_null("NavigationAgent3D")
	nav_agent.velocity_computed.connect(_on_velocity_computed_triggered)

func move_to(target_pos: Vector3) -> void:
	nav_agent.target_position = target_pos
	if nav_agent.is_navigation_finished(): return
	var dir: Vector3 = (nav_agent.get_next_path_position() - actor.global_position).normalized()
	nav_agent.set_velocity(dir * nav_agent.max_speed)

func _on_velocity_computed_triggered(v: Vector3) -> void:
	actor.velocity = v
