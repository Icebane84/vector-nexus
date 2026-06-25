# [GVRN] [UAM-V15]
# Artifact ID:   COMP.Camera.LockOn
# Description:   Rotational binding logic for third-person camera targeting.
#                When TargetingEye nodes are registered via `register_eye()`,
#                their spatially-filtered lists are used for candidate discovery.
#                Falls back to the global "enemy" group scan transparently.
#                Phoenix-Pure: SKILL-001 backing fields, SKILL-005 named methods,
#                SKILL-008 no await.
# Version:       2.0 [SOVEREIGN]
# Relationships: OPTIONALLY_CONSUMES(COMP.Targeting.Eye), CONSUMED_BY(PlayerCamera)
# Status:        [CANONIZED]

extends Node3D
class_name LockOnComponent

const CamTarget = preload("res://scripts/components/lib/Camera.Target.gd")

# ---------------------------------------------------------------------------
# Signals  (SKILL-020)
# ---------------------------------------------------------------------------

signal target_changed(target: Node3D)

# ---------------------------------------------------------------------------
# Exports  (SKILL-001: Backing-Field Resilience)
# ---------------------------------------------------------------------------

var _max_lock_distance: float = 30.0
@export var max_lock_distance: float:
	get: return _max_lock_distance
	set(v): _max_lock_distance = v

## Optional: directly inject mock targets for unit tests.
@export var _mock_targets: Array[Node] = []

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

## Registered TargetingEye instances (optional, enhances spatial filtering).
var _eyes: Array = []

var _current_target: Node3D = null
## Setting current_target emits target_changed and drives all downstream systems.
var current_target: Node3D:
	get: return _current_target
	set(v):
		if _current_target != v:
			_current_target = v
			target_changed.emit(v)

# ---------------------------------------------------------------------------
# Eye registration  (SKILL-005: Named method connectivity)
# ---------------------------------------------------------------------------

## Register a TargetingEye with this LockOn component.
## The eye's `list_changed` signal will refresh internal cache when it fires.
func register_eye(eye: TargetingEye) -> void:
	if eye in _eyes:
		return
	_eyes.append(eye)
	# SKILL-005: Named method — no lambda.
	eye.list_changed.connect(_on_eye_list_changed)

## Unregister a previously registered eye.
func unregister_eye(eye: TargetingEye) -> void:
	_eyes.erase(eye)
	if eye.list_changed.is_connected(_on_eye_list_changed):
		eye.list_changed.disconnect(_on_eye_list_changed)

func _on_eye_list_changed(_list: Array) -> void:
	# Refresh the current target validity whenever any eye updates.
	# If the current target is no longer seen by any eye, clear it.
	if is_instance_valid(_current_target) and _eyes.size() > 0:
		var still_visible: bool = false
		for eye: TargetingEye in _eyes:
			if _current_target in eye.target_list:
				still_visible = true
				break
		if not still_visible:
			current_target = null

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Find the closest valid target from the camera's centre.
func find_closest_target(camera: Camera3D) -> Node3D:
	return CamTarget.find_closest_target(global_position, camera, _get_all_targets())

## Cycle to a nearby target in the given screen-space flick direction.
func find_target_in_direction(camera: Camera3D, flick_dir: Vector2) -> Node3D:
	if not is_instance_valid(current_target):
		return find_closest_target(camera)
	return CamTarget.find_flick_target(
		global_position, camera, current_target, _get_all_targets(), flick_dir
	)

# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _get_all_targets() -> Array:
	## Returns candidate targets.
	## Priority: mock > eye-filtered > global group scan.
	if _mock_targets.size() > 0:
		return _mock_targets

	if _eyes.size() > 0:
		# Merge all eye lists, deduplicate, and apply distance filter.
		var merged: Array = []
		for eye: TargetingEye in _eyes:
			for t: Node3D in eye.target_list:
				if t not in merged and is_instance_valid(t):
					merged.append(t)
		return merged.filter(func(t: Node3D) -> bool:
			return global_position.distance_to(t.global_position) <= _max_lock_distance
		)

	# Fallback: global group scan with distance filter.
	var all: Array[Node] = get_tree().get_nodes_in_group("enemy")
	return all.filter(func(t: Node) -> bool:
		return is_instance_valid(t) and t is Node3D and \
		global_position.distance_to((t as Node3D).global_position) <= _max_lock_distance
	)
