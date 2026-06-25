# [GVRN]
# Artifact ID: COMM.Avatar.State.Move
# Description: Standard movement logic with Root Motion Extraction.

extends "res://scripts/components/state_machine/FABRIC.Logic.State.gd"
class_name PlayerMoveState

const MoveLib = preload("res://scripts/entities/player/lib/Move.Library.gd")
const ActionTrans = preload("res://scripts/entities/player/lib/Action.Transitions.gd")
const Orient = preload("res://scripts/entities/player/lib/Actor.Orientation.gd")

var _speed: float = 7.0
@export var speed: float:
	get: return _speed
	set(v): _speed = maxf(0.0, v)

var _rotation_speed: float = 12.0
@export var rotation_speed: float:
	get: return _rotation_speed
	set(v): _rotation_speed = maxf(0.0, v)

func enter(_msg: Dictionary = {}) -> void:
	ActionTrans.play_state_animation(animation_tree, anim, &"walk")

func physics_update(delta: float) -> void:
	if not is_instance_valid(actor): return
	if _check_environmental_transitions(): return

	var input: Vector2 = actor.get_movement_input() if actor.has_method(&"get_movement_input") else Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")

	# Determine movement direction
	var move_dir := Vector3.ZERO
	if input.length() >= 0.1:
		actor.input_dir = input
		move_dir = MoveLib.get_camera_relative_dir(input, camera)
	else:
		actor.input_dir = Vector2.ZERO
		_handle_idle_transition()

	var target_locked: Node3D = null
	if camera and camera.lock_on and is_instance_valid(camera.lock_on.current_target):
		target_locked = camera.lock_on.current_target

	# Store previous rotation for turn leaning
	var prev_rot_y = actor.visuals.rotation.y

	if target_locked:
		actor.strafing = true
		var face_dir: Vector3 = (target_locked.global_position - actor.global_position).normalized()
		actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, atan2(-face_dir.x, -face_dir.z), rotation_speed * delta)
		
		var forward_vector: Vector3 = -actor.visuals.global_transform.basis.z.normalized()
		actor.strafe_cross_product = -forward_vector.cross(move_dir).y
		actor.move_dot_product = forward_vector.dot(move_dir)
	else:
		actor.strafing = false
		if input.length() >= 0.1:
			Orient.apply_lerped_rotation(actor, move_dir, rotation_speed, delta)

	# Procedural Lean Calculation
	var delta_rot_y = wrapf(actor.visuals.rotation.y - prev_rot_y, -PI, PI)
	var turn_rate = delta_rot_y / delta
	var lean_target = clampf(turn_rate * 0.08, -0.25, 0.25) if input.length() >= 0.1 else 0.0
	actor.visuals.rotation.z = lerp(actor.visuals.rotation.z, lean_target, 1.0 - exp(-10.0 * delta))

	_apply_movement_velocity(move_dir, delta)

	var stamina: Node = actor.get_stamina_component() if actor.has_method(&"get_stamina_component") else null
	ActionTrans.check_standard_actions(state_machine, stamina)

func _check_environmental_transitions() -> bool:
	if not actor.is_on_floor():
		state_machine.transition_to(&"Fall")
		return true
	if Input.is_action_just_pressed(&"jump"):
		state_machine.transition_to(&"Jump")
		return true
	return false

func _handle_idle_transition() -> void:
	if actor.velocity.length() < 0.1:
		actor.velocity = Vector3.ZERO
		state_machine.transition_to(&"Idle")

func _apply_movement_velocity(dir: Vector3, delta: float) -> void:
	var vel: Vector3 = MoveLib.get_velocity_from_root_motion(animation_tree, actor.visuals, delta)
	if vel.length_squared() > 0.00001:
		actor.velocity.x = vel.x
		actor.velocity.z = vel.z
	else:
		# Smooth acceleration & deceleration stops using exponential lerp
		var target_vel = dir * speed
		actor.velocity.x = lerp(actor.velocity.x, target_vel.x, 1.0 - exp(-12.0 * delta))
		actor.velocity.z = lerp(actor.velocity.z, target_vel.z, 1.0 - exp(-12.0 * delta))
