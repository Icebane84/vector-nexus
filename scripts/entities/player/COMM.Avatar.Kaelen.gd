"""
[GVRN]
Artifact ID:   COMM.Avatar.Kaelen
Description:   Kaelen test vessel controller for prototyping the Instability System.
               Fully decoupled from the main player logic.
"""
extends CharacterBody3D
class_name Kaelen

@export_group("Dependencies")
@export var camera: PlayerCamera
@export var visuals: Node3D

@export_group("Stats")
var _speed: float = 6.0
@export var speed: float:
	get: return _speed
	set(v):
		_speed = v
var _rotation_speed: float = 12.0
@export var rotation_speed: float:
	get: return _rotation_speed
	set(v):
		_rotation_speed = v

const ACTION_MOVE_LEFT = &"move_left"
const ACTION_MOVE_RIGHT = &"move_right"
const ACTION_MOVE_FORWARD = &"move_forward"
const ACTION_MOVE_BACK = &"move_back"

func _ready() -> void:
	if camera:
		camera.target = self

func _physics_process(delta: float) -> void:
	var input := Input.get_vector(
		ACTION_MOVE_LEFT,
		ACTION_MOVE_RIGHT,
		ACTION_MOVE_FORWARD,
		ACTION_MOVE_BACK,
	)
	var dir := Vector3.ZERO
	
	if input.length() > 0.1:
		# Calculate movement relative to the camera's orientation
		var cam_basis := camera.global_transform.basis if camera else global_transform.basis
		var forward := -Vector3(cam_basis.z.x, 0.0, cam_basis.z.z).normalized()
		var right := Vector3(cam_basis.x.x, 0.0, cam_basis.x.z).normalized()
		dir = (forward * input.y + right * input.x).normalized()
		
		# Smoothly rotate the visual mesh towards the movement direction
	if visuals:
		var target_angle := atan2(-dir.x, -dir.z)
		var target_y := lerp_angle(
				visuals.rotation.y,
				target_angle,
				rotation_speed * delta,
			)
		visuals.rotation.y = target_y

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	move_and_slide()
