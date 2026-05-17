# scripts/entities/player/lib/Camera.Processor.gd
extends RefCounted

## PHOENIX: Camera Processing Library

static func handle_free_look(arm: Node3D, relative: Vector2, sensitivity: float, min_p: float, max_p: float) -> void:
	arm.rotation.y -= relative.x * sensitivity
	arm.rotation.x -= relative.y * sensitivity
	arm.rotation.x = clamp(arm.rotation.x, min_p, max_p)

static func track_target(arm: Node3D, target: Node3D, delta: float) -> void:
	if not is_instance_valid(target): return
	
	var target_pos: Vector3 = target.global_position
	var dir: Vector3 = (target_pos - arm.global_position).normalized()
	
	arm.rotation.y = lerp_angle(arm.rotation.y, atan2(-dir.x, -dir.z), 10.0 * delta)
	arm.rotation.x = lerp_angle(arm.rotation.x, asin(dir.y), 10.0 * delta)
