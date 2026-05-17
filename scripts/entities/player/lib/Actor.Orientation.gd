# scripts/entities/player/lib/Actor.Orientation.gd
extends RefCounted

## PHOENIX: Actor Orientation Logic Library
## Decouples rotation and facing logic from state machines and physics.

static func orient_to_input(actor: Node3D, camera: Node3D, input: Vector2) -> void:
    if not (actor and actor.get("visuals") and camera): return
    if input.length() <= 0.1: return
    
    var cam_basis: Basis = camera.global_transform.basis
    var forward := -Vector3(cam_basis.z.x, 0, cam_basis.z.z).normalized()
    var right := Vector3(cam_basis.x.x, 0, cam_basis.x.z).normalized()
    var dir := (forward * -input.y + right * input.x).normalized()
    
    actor.visuals.rotation.y = atan2(-dir.x, -dir.z)

static func orient_to_target(actor: Node3D, target: Node3D) -> void:
    if not (actor and actor.get("visuals") and is_instance_valid(target)): return
    var face_dir := (target.global_position - actor.global_position).normalized()
    actor.visuals.rotation.y = atan2(-face_dir.x, -face_dir.z)

static func apply_lerped_rotation(actor: Node3D, dir: Vector3, speed: float, delta: float) -> void:
    if dir.length() > 0.1 and actor and actor.get("visuals"):
        var target_angle := atan2(-dir.x, -dir.z)
        actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, target_angle, speed * delta)

static func get_facing_dir(actor: Node3D) -> Vector3:
    if not (actor and actor.get("visuals")): return Vector3.ZERO
    return -actor.visuals.global_transform.basis.z.normalized()
