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
	if input.length() < 0.1:
		_handle_idle_transition()
		return

	actor.input_dir = input
	var move_dir: Vector3 = MoveLib.get_camera_relative_dir(input, camera)
	
	var target_locked: Node3D = null
	if camera and camera.lock_on and is_instance_valid(camera.lock_on.current_target):
		target_locked = camera.lock_on.current_target
		
	if target_locked:
		actor.strafing = true
		var face_dir: Vector3 = (target_locked.global_position - actor.global_position).normalized()
		actor.visuals.rotation.y = lerp_angle(actor.visuals.rotation.y, atan2(-face_dir.x, -face_dir.z), rotation_speed * delta)
		
		var forward_vector: Vector3 = -actor.visuals.global_transform.basis.z.normalized()
		actor.strafe_cross_product = -forward_vector.cross(move_dir).y
		actor.move_dot_product = forward_vector.dot(move_dir)
	else:
		actor.strafing = false
		Orient.apply_lerped_rotation(actor, move_dir, rotation_speed, delta)
		
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
		actor.velocity.x = dir.x * speed
		actor.velocity.z = dir.z * speed
