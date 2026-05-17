extends Node
class_name MovementBlackbox

## PHOENIX ARCHITECT: VISUAL CORTEX LOG v1.0
## Tracks frame-by-frame locomotion data for jitter analysis.

@export var target_node: CharacterBody3D
var _log_frequency: int = 1 # Every N frames
@export var log_frequency: int:
	get: return _log_frequency
	set(v):
		_log_frequency = v
var _max_samples: int = 600 # 10 seconds at 60fps
@export var max_samples: int:
	get: return _max_samples
	set(v):
		_max_samples = v

var _log_data: Array = []
var _frame_count: int = 0
var _active: bool = true

func _ready() -> void:
	if not target_node:
		target_node = get_parent() as CharacterBody3D
	
	if target_node:
		print("[BLACKBOX] Started logging for: ", target_node.name)
	else:
		_active = false
		push_error("[BLACKBOX] Target node not found. Logging disabled.")

func _physics_process(_delta: float) -> void:
	if not _active or _frame_count >= max_samples:
		if _active and _frame_count >= max_samples:
			_save_log()
			_active = false
		return

	if _frame_count % log_frequency == 0:
		_capture_frame()
	
	_frame_count += 1

func _capture_frame() -> void:
	var state_name: String = "UNKNOWN"
	var sm: Node = target_node.get_node_or_null("StateMachine")
	if sm and sm.get("current_state"):
		state_name = sm.get("current_state").name

	var frame_entry: Dictionary = {
		"frame": _frame_count,
		"pos": {
			"x": target_node.global_position.x,
			"y": target_node.global_position.y,
			"z": target_node.global_position.z
		},
		"vel": {
			"x": target_node.velocity.x,
			"y": target_node.velocity.y,
			"z": target_node.velocity.z
		},
		"state": state_name,
		"is_on_floor": target_node.is_on_floor()
	}
	_log_data.append(frame_entry)

func _save_log() -> void:
	var file_path: String = "res://blackbox_movement_log.json"
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string: String = JSON.stringify(_log_data, "\t")
		file.store_string(json_string)
		file.close()
		print("[BLACKBOX] Log saved to: ", file_path)
	else:
		push_error("[BLACKBOX] Failed to save log file.")

func stop_and_save() -> void:
	_save_log()
	_active = false
