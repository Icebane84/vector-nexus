# [GVRN] [UAM-V15]
# Artifact ID:   COMP.Locomotion.FootfallSensor
# Description:   Per-foot ground contact sensor for the Footstep Audio subsystem.
#                Attach one sensor to each foot BoneAttachment3D on the character
#                skeleton. The sensor emits `foot_stepped` when the foot makes
#                contact with the floor and `foot_lifted` when it leaves.
#                Phoenix-Pure: SKILL-006 force_raycast_update, no await (SKILL-008).
# Version:       1.0 [SOVEREIGN]
# Relationships: CONSUMED_BY(COMP.Locomotion.FootstepAudio)
# Status:        [CANONIZED]
# Source:        Ported from footfall_system.gd (Cats-Godot4-Modular-Souls-like-Template)

extends BoneAttachment3D
class_name FootfallSensor

# ---------------------------------------------------------------------------
# Signals  (SKILL-020: Agent-Synapse Metadata)
# ---------------------------------------------------------------------------

## Emitted the frame the foot makes ground contact. Carries the world-space
## impact position and the surface normal for surface-type detection.
signal foot_stepped(position: Vector3, normal: Vector3)

## Emitted the frame the foot leaves the ground.
signal foot_lifted()

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## Node path to the RayCast3D child used for floor detection.
## The cast should point downward (local -Y or adjusted via x-rotation).
@export_node_path("RayCast3D") var floorcast_path: NodePath = NodePath("Floorcast")

# ---------------------------------------------------------------------------
# State  (SKILL-001: Backing-Field Resilience)
# ---------------------------------------------------------------------------

var _on_floor: bool = true
var _floorcast: RayCast3D = null

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_floorcast = get_node_or_null(floorcast_path) as RayCast3D
	if not _floorcast:
		push_warning("FootfallSensor [%s]: No RayCast3D found at path '%s'. Sensor disabled." % [name, floorcast_path])

func _physics_process(_delta: float) -> void:
	if not _floorcast:
		return
	# SKILL-006: Force an immediate physics query so the result is current-frame accurate.
	_floorcast.force_raycast_update()
	_poll_contact()

# ---------------------------------------------------------------------------
# Private — contact polling  (SKILL-003: Atomic State Transitions)
# ---------------------------------------------------------------------------

func _poll_contact() -> void:
	var colliding: bool = _floorcast.is_colliding()

	if _on_floor and not colliding:
		# Foot just left the ground.
		_on_floor = false
		foot_lifted.emit()

	elif not _on_floor and colliding:
		# Foot just touched the ground.
		_on_floor = true
		foot_stepped.emit(
			_floorcast.get_collision_point(),
			_floorcast.get_collision_normal()
		)
