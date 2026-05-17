# object_pool.gd
class_name ObjectPool
extends Node

## PHOENIX ARCHITECT: SKILL-GAM-001 ALIGNMENT
## ANTI_PATTERN_ZERO: Prevents object creation in hot loops via pooling.

@export var pooled_scene: PackedScene
var _initial_size: int = 20
@export var initial_size: int:
	get: return _initial_size
	set(v):
		_initial_size = v
@export var can_grow: bool = true

var _available: Array[Node] = []
var _in_use: Array[Node] = []

func _ready() -> void:
	if not pooled_scene:
		push_error("ObjectPool Error: pooled_scene must be assigned in the Inspector.")
		return
	_initialize_pool()

func _initialize_pool() -> void:
	for i in initial_size:
		_create_instance()

func _create_instance() -> Node:
	var instance: Node = pooled_scene.instantiate() as Node
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	instance.visible = false
	add_child(instance)
	_available.append(instance)

	if instance.has_signal("returned_to_pool"):
		instance.returned_to_pool.connect(_return_to_pool.bind(instance))

	return instance

func get_instance() -> Node:
	var instance: Node

	if _available.is_empty():
		if can_grow:
			instance = _create_instance()
			_available.erase(instance)
		else:
			push_warning("Pool exhausted and cannot grow")
			return null
	else:
		instance = _available.pop_back()

	instance.process_mode = Node.PROCESS_MODE_INHERIT
	instance.visible = true
	_in_use.append(instance)

	if instance.has_method("on_spawn"):
		instance.on_spawn()

	return instance

func _return_to_pool(instance: Node) -> void:
	if not instance in _in_use:
		return

	_in_use.erase(instance)

	if instance.has_method("on_despawn"):
		instance.on_despawn()

	instance.process_mode = Node.PROCESS_MODE_DISABLED
	instance.visible = false
	_available.append(instance)
