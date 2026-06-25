# [GVRN] [UAM-V15]
# Artifact ID:   COMP.Targeting.Eye
# Description:   Volumetric enemy detection sensor for the LockOn subsystem.
#                Maintains a live, filtered list of targetable bodies within
#                its collision volume and emits `list_changed` when it updates.
#                Phoenix-Pure: no `await`, no lambdas on Autoloads (SKILL-005).
# Version:       1.0 [SOVEREIGN]
# Relationships: CONSUMED_BY(COMP.Camera.LockOn), CONSUMES(enemy group)
# Status:        [CANONIZED]
# Source:        Ported from eye_list.gd (Cats-Godot4-Modular-Souls-like-Template)

extends Area3D
class_name TargetingEye

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## The Godot group name used to classify targetable enemies.
@export var target_group: StringName = &"enemy"

# ---------------------------------------------------------------------------
# Signals  (SKILL-020: Agent-Synapse Metadata)
# ---------------------------------------------------------------------------

## Emitted whenever the internal target list is rebuilt (entry or exit).
signal list_changed(new_list: Array)

# ---------------------------------------------------------------------------
# State  (SKILL-001: Backing-Field Resilience)
# ---------------------------------------------------------------------------

var _target_list: Array[Node3D] = []
## Read-only live list of valid targets currently inside this eye's volume.
var target_list: Array[Node3D]:
	get: return _target_list

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# SKILL-005: Named methods only — no anonymous lambdas on persistent nodes.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# ---------------------------------------------------------------------------
# Private — collision callbacks
# ---------------------------------------------------------------------------

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(target_group):
		_rebuild_list()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(target_group):
		# Remove immediately without a full raycast sweep.
		_target_list = _target_list.filter(
			func(t: Node3D) -> bool: return is_instance_valid(t) and t != body
		)
		list_changed.emit(_target_list.duplicate())

# ---------------------------------------------------------------------------
# Private — list management
# ---------------------------------------------------------------------------

func _rebuild_list() -> void:
	## Queries overlapping bodies and keeps only valid group members.
	var raw: Array[Node3D] = []
	for b: Node3D in get_overlapping_bodies():
		if is_instance_valid(b) and b.is_in_group(target_group):
			raw.append(b)
	_target_list = raw
	list_changed.emit(_target_list.duplicate())
