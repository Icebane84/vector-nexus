# [GVRN]
# Artifact ID: COMP.Camera.LockOn
# Description: Rotational binding logic for third-person camera targeting.

extends Node3D
class_name LockOnComponent

const CamTarget = preload("res://scripts/components/lib/Camera.Target.gd")

signal target_changed(target: Node3D)

var _max_lock_distance: float = 30.0
@export var max_lock_distance: float:
	get: return _max_lock_distance
	set(v): _max_lock_distance = v

@export var _mock_targets: Array[Node] = []

var _current_target: Node3D = null
var current_target: Node3D:
	get: return _current_target
	set(v):
		if _current_target != v:
			_current_target = v
			target_changed.emit(v)

func find_closest_target(camera: Camera3D) -> Node3D:
	return CamTarget.find_closest_target(global_position, camera, _get_all_targets())

func find_target_in_direction(camera: Camera3D, flick_dir: Vector2) -> Node3D:
	if not is_instance_valid(current_target):
		return find_closest_target(camera)
	return CamTarget.find_flick_target(global_position, camera, current_target, _get_all_targets(), flick_dir)

func _get_all_targets() -> Array:
	if _mock_targets.size() > 0: return _mock_targets
	
	var all: Array[Node] = get_tree().get_nodes_in_group("enemy")
	return all.filter(func(t: Node) -> bool: 
		return is_instance_valid(t) and t is Node3D and \
		global_position.distance_to((t as Node3D).global_position) <= max_lock_distance
	)
