"""
[GVRN] [COMM] [ENEMY] [STATE]
Artifact ID: COMM.Enemy.State.Chase
"""
extends State
class_name AIChaseState

# 1. Strictly Typed Variables
@export_group("Detection")
var _attack_range: float = 2.0
@export var attack_range: float:
	get: return _attack_range
	set(v):
		_attack_range = v
var _lose_interest_range: float = 15.0
@export var lose_interest_range: float:
	get: return _lose_interest_range
	set(v):
		_lose_interest_range = v
var _move_speed: float = 5.0
@export var move_speed: float:
	get: return _move_speed
	set(v):
		_move_speed = v
@export var los_ray: RayCast3D


func enter(_msg: Dictionary = {}) -> void:
	if anim and anim.has_animation(&"move"): 
		anim.play(&"move")

func physics_update(_delta: float) -> void:
	if not actor: return
	
	# Target Acquisition Module
	if not actor.get("target"):
		_find_new_target()
		return

	var target: Node3D = actor.target
	var dist: float = actor.global_position.distance_to(target.global_position)
	
	# Transition Logic using Enums (Internal logic maps to state_machine strings)
	if _check_transitions(dist, target):
		return

	# Movement Execution
	_execute_movement(target.global_position)

func _find_new_target() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")

	if players.size() > 0:
		actor.target = players[0]
	else:
		state_machine.transition_to("AIIdleState")

# AIChaseState.gd
func _check_transitions(dist: float, target: Node3D) -> bool:
	if dist < attack_range:
		state_machine.transition_to(&"AIAttackState") 
		return true
		
	# Line of Sight & Interest Check
	if dist > lose_interest_range or not _has_line_of_sight(target):
		actor.target = null
		state_machine.transition_to(&"AIIdleState") 
		return true
	
	return false

func _has_line_of_sight(target: Node3D) -> bool:
	if not los_ray: return true # Fallback if raycast is missing
	los_ray.look_at(target.global_position + Vector3.UP)
	return los_ray.is_colliding() and los_ray.get_collider() == target

func _execute_movement(target_pos: Vector3) -> void:
	var direction: Vector3 = (target_pos - actor.global_position).normalized()
	actor.velocity = direction * move_speed
	actor.move_and_slide()
