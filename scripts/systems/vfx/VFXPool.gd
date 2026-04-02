# res://scripts/systems/vfx/VFXPool.gd
extends Node

# Removal of class_name prevents "Hides Autoload Singleton" error
@export var vfx_scene: PackedScene

# Using Node3D instead of VFXInstance avoids parsing race conditions in Autoloads
var _pool: Array[Node3D] = []
var _next: int = 0

func _ready() -> void:
	Director.vfx_pool = self
	
	if not vfx_scene:
		push_error("PHOENIX_LOG: VfxPool lacks a vfx_scene template.")
		return
		
	for i in range(25):
		var inst = vfx_scene.instantiate()
		add_child(inst)
		inst.hide()
		_pool.append(inst)

## Call Down: Spawns an effect from the circular buffer
func spawn_vfx(pos: Vector3) -> void:
	if _pool.is_empty(): 
		return
		
	var inst = _pool[_next]
	# Safe casting during execution rather than at the script header
	if inst.has_method(&"play"):
		inst.call(&"play", pos)
		
	_next = (_next + 1) % _pool.size()
