# [GVRN]
# Artifact ID: COMM.Avatar.State.Dodge
# Description: Standard dodge roll with Root Motion Extraction and Locked Orientation.

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerDodgeState

const MoveLib = preload("res://scripts/entities/player/lib/Move.Library.gd")
const ActionLib = preload("res://scripts/entities/player/lib/Action.Transitions.gd")
const Orient = preload("res://scripts/entities/player/lib/Actor.Orientation.gd")

var _duration: float = 0.4
@export var duration: float:
	get: return _duration
	set(v): _duration = v

var _force: float = 12.0
@export var force: float:
	get: return _force
	set(v): _force = v

var _timer: float = 0.0
var _dodge_dir: Vector3 = Vector3.ZERO

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_timer = duration
	ActionLib.play_state_animation(animation_tree, anim, &"dodge")
	
	if hurtbox: hurtbox.is_invincible = true
	
	_dodge_dir = _calculate_dodge_dir()
	_apply_orientation()
	actor.velocity = _dodge_dir * force

func physics_update(delta: float) -> void:
	_apply_movement_logic(delta)
	_timer -= delta
	if _timer <= 0:
		state_machine.transition_to(&"Move")

func exit() -> void:
	super.exit()
	if hurtbox: hurtbox.is_invincible = false

func _calculate_dodge_dir() -> Vector3:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input.length() > 0.1:
		return MoveLib.get_camera_relative_dir(input, camera)
	return Orient.get_facing_dir(actor)

func _apply_orientation() -> void:
	var locked_target: Node3D = actor.get("locked_target") as Node3D
	if is_instance_valid(locked_target):
		Orient.orient_to_target(actor, locked_target)
	else:
		actor.visuals.rotation.y = atan2(-_dodge_dir.x, -_dodge_dir.z)

func _apply_movement_logic(delta: float) -> void:
	var root_vel: Vector3 = MoveLib.get_velocity_from_root_motion(animation_tree, actor.visuals, delta)
	if root_vel.length_squared() > 0.00001:
		actor.velocity.x = root_vel.x
		actor.velocity.z = root_vel.z
	else:
		actor.velocity = _dodge_dir * force
