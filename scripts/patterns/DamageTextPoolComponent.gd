extends Node3D
class_name DamageTextPoolComponent

## PHOENIX ARCHITECT: SKILL-002 ALIGNMENT
## Localized, Zero-Allocation Object Pool for floating combat text.

var _pool_size: int = 5
@export var pool_size: int:
	get: return _pool_size
	set(v):
		_pool_size = v
@export var damage_text_scene: PackedScene

var _pool: Array[FloatingDamageText] = []
var _pool_index: int = 0

func _ready() -> void:
	if not damage_text_scene:
		push_error("DamageTextPoolComponent: damage_text_scene is null.")
		return
		
	# Pre-allocate the pool to avoid runtime stutters
	for i in range(pool_size):
		var text_node := damage_text_scene.instantiate() as FloatingDamageText
		if text_node:
			add_child(text_node)
			text_node.hide()
			_pool.append(text_node)

func display_damage(amount: float, _source: Node = null) -> void:
	if _pool.is_empty():
		return
		
	var text_node := _pool[_pool_index]
	_pool_index = (_pool_index + 1) % pool_size
	
	# Spawn slightly offset to avoid text overlapping perfectly
	var offset := Vector3(randf_range(-0.5, 0.5), 1.0, randf_range(-0.5, 0.5))
	text_node.activate(amount, global_position + offset)
