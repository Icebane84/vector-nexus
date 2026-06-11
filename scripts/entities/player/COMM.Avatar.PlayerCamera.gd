# [GVRN]
# Artifact ID:   COMM.Avatar.PlayerCamera
# Description:   Active 3rd person camera controller with mouse look and smooth orbiting.

extends SpringArm3D
class_name PlayerCamera

const LockOnComp = preload("res://scripts/components/COMP.Camera.LockOn.gd")
const CamProc = preload("res://scripts/entities/player/lib/Camera.Processor.gd")

@export_group("Camera Settings")
var _mouse_sensitivity: float = 0.003
@export var mouse_sensitivity: float:
	get: return _mouse_sensitivity
	set(v): _mouse_sensitivity = v

var _min_pitch: float = -PI / 4.0
@export var min_pitch: float:
	get: return _min_pitch
	set(v): _min_pitch = v

var _max_pitch: float = PI / 3.0
@export var max_pitch: float:
	get: return _max_pitch
	set(v): _max_pitch = v

# SKILL-001: Backing-Field Resilience
var _vertical_offset: float = 1.5
@export var vertical_offset: float:
	get: return _vertical_offset
	set(v): _vertical_offset = v

var target: Node3D:
	set(v):
		target = v
		if target is CollisionObject3D:
			clear_excluded_objects()
			add_excluded_object(target.get_rid())

const NORMAL_FOV: float = 75.0
const SPRINT_FOV: float = 85.0

var _trauma: float = 0.0
var trauma: float:
	get: return _trauma
	set(v): _trauma = clampf(v, 0.0, 1.0)

var _trauma_decay: float = 2.0
var trauma_decay: float:
	get: return _trauma_decay
	set(v): _trauma_decay = v

var _max_yaw_shake: float = 5.0
var max_yaw_shake: float:
	get: return _max_yaw_shake
	set(v): _max_yaw_shake = v

var _max_pitch_shake: float = 5.0
var max_pitch_shake: float:
	get: return _max_pitch_shake
	set(v): _max_pitch_shake = v

var _smooth_speed: float = 10.0
@export var smooth_speed: float:
	get: return _smooth_speed
	set(v): _smooth_speed = v

var _camera: Camera3D
var lock_on: LockOnComp

signal target_locked(target: Node3D)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	top_level = true
	_camera = get_node_or_null("Camera3D") as Camera3D
	lock_on = LockOnComp.new()
	add_child(lock_on)
	# SKILL-005: Avoid lambdas for connections
	lock_on.target_changed.connect(_on_lock_target_changed)

func _on_lock_target_changed(t: Node3D) -> void:
	target_locked.emit(t)

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused: return
	_handle_lock_toggle(event)
	_handle_camera_input(event)
	_handle_debug_input(event)

func _handle_lock_toggle(event: InputEvent) -> void:
	if event.is_action_pressed("lock_on"):
		if is_instance_valid(lock_on.current_target):
			lock_on.current_target = null
		elif _camera:
			lock_on.current_target = lock_on.find_closest_target(_camera)

func _handle_camera_input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		return
		
	if is_instance_valid(lock_on.current_target):
		_handle_target_flick(event.relative)
	else:
		CamProc.handle_free_look(self, event.relative, mouse_sensitivity, min_pitch, max_pitch)

func _handle_target_flick(rel: Vector2) -> void:
	if abs(rel.x) > 40.0:
		var new_t: Node3D = lock_on.find_target_in_direction(_camera, Vector2(sign(rel.x), 0))
		if new_t: lock_on.current_target = new_t


func _handle_debug_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if target:
		global_position = target.global_position + Vector3(0, vertical_offset, 0)

	if is_instance_valid(lock_on.current_target):
		CamProc.track_target(self, lock_on.current_target, delta)

	# --- Kaelen / Witness Camera Integration ---
	if _camera:
		# 1. FOV Scaling on Sprint (Adrenaline effect)
		var target_fov: float = NORMAL_FOV
		if InputMap.has_action(&"sprint") and Input.is_action_pressed(&"sprint"):
			target_fov = SPRINT_FOV
		elif InputMap.has_action(&"dodge") and Input.is_action_pressed(&"dodge"):
			target_fov = SPRINT_FOV
		_camera.fov = lerp(_camera.fov, target_fov, delta * smooth_speed)
		
		# 2. Screenshake / Trauma process
		if trauma > 0.0:
			trauma = maxf(trauma - trauma_decay * delta, 0.0)
			var shake: float = trauma * trauma
			_camera.rotation_degrees.y = randf_range(-max_yaw_shake, max_yaw_shake) * shake
			_camera.rotation_degrees.x = randf_range(-max_pitch_shake, max_pitch_shake) * shake
		else:
			_camera.rotation_degrees = Vector3.ZERO

func apply_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)
