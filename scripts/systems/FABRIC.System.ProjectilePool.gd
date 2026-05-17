# [GVRN]
# Artifact ID:   FABRIC.System.ProjectilePool
# Description:   Circular buffer for combat projectiles.
# Author:        Architect

extends Node3D
class_name ProjectilePool

@export var projectile_scene: PackedScene
var _pool_size: int = 30
@export var pool_size: int:
	get: return _pool_size
	set(v):
		_pool_size = v

var _pool: Array[PooledProjectile] = []
var _next_index: int = 0

func _ready() -> void:
	_initialize_pool()

func _initialize_pool() -> void:
	if not projectile_scene:
		push_error("ProjectilePool: projectile_scene is not assigned.")
		return
		
	for i in range(pool_size):
		var inst := projectile_scene.instantiate() as PooledProjectile
		inst.hide()
		inst.process_mode = Node.PROCESS_MODE_INHERIT
		add_child(inst)
		_pool.append(inst)

func fire_projectile(start_pos: Vector3, direction: Vector3) -> void:
	if _pool.is_empty(): return
	
	var proj := _pool[_next_index]
	# Circular pointer wraps back to 0 when hitting pool_size
	_next_index = (_next_index + 1) % pool_size 
	
	proj.fire(start_pos, direction)
