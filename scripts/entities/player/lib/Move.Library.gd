# scripts/entities/player/lib/Move.Library.gd
extends RefCounted

## PHOENIX: Movement Logic Library
## Handles camera-relative direction and root motion extraction.

static func get_camera_relative_dir(input: Vector2, camera: Node3D) -> Vector3:
    if not camera: return Vector3.ZERO
    var cam_basis := camera.global_transform.basis
    var forward := -Vector3(cam_basis.z.x, 0, cam_basis.z.z).normalized()
    var right := Vector3(cam_basis.x.x, 0, cam_basis.x.z).normalized()
    return (forward * -input.y + right * input.x).normalized()

static func get_velocity_from_root_motion(animation_tree: AnimationTree, actor_visuals: Node3D, delta: float) -> Vector3:
    if not animation_tree: return Vector3.ZERO
    var root_motion: Vector3 = animation_tree.get_root_motion_position()
    if root_motion.length_squared() > 0.00001:
        return (actor_visuals.global_transform.basis * root_motion) / delta
    return Vector3.ZERO
