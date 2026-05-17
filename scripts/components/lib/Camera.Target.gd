# scripts/components/lib/Camera.Target.gd
extends RefCounted

## PHOENIX: Camera Targeting Utilities

static func find_closest_target(origin: Vector3, camera: Camera3D, targets: Array) -> Node3D:
	var best_target: Node3D = null
	var min_dist: float = INF
	var center: Vector2 = camera.get_viewport().get_visible_rect().size / 2.0
	
	for t in targets:
		if _is_valid_candidate(t, origin, camera):
			var dist: float = camera.unproject_position((t as Node3D).global_position).distance_to(center)
			if dist < min_dist:
				min_dist = dist
				best_target = t
	return best_target

static func find_flick_target(origin: Vector3, camera: Camera3D, current: Node3D, targets: Array, flick_dir: Vector2) -> Node3D:
	if not is_instance_valid(current): return null
	
	var best_target: Node3D = null
	var min_score: float = INF
	var current_pos: Vector2 = camera.unproject_position(current.global_position)
	var flick_norm: Vector2 = flick_dir.normalized()
	
	for t in targets:
		if t == current or not _is_valid_candidate(t, origin, camera): continue
		
		var t_pos: Vector2 = camera.unproject_position((t as Node3D).global_position)
		var dir_to_t: Vector2 = (t_pos - current_pos).normalized()
		var dot: float = dir_to_t.dot(flick_norm)
		
		if dot > 0.2:
			var score: float = t_pos.distance_to(current_pos) * (1.1 - dot)
			if score < min_score:
				min_score = score
				best_target = t
	return best_target

static func _is_valid_candidate(t: Node, origin: Vector3, camera: Camera3D) -> bool:
	if not is_instance_valid(t) or not t is Node3D: return false
	if camera.is_position_behind(t.global_position): return false
	return true
