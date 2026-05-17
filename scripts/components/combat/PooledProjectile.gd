# [GVRN]
# Artifact ID:   COMP.Combat.PooledProjectile
# Description:   Zero-Allocation projectile logic.
# Author:        Architect

extends Area3D
class_name PooledProjectile

signal returned_to_pool(proj: PooledProjectile)

var _speed: float = 20.0
@export var speed: float:
	get: return _speed
	set(v):
		_speed = v
var _max_lifetime: float = 3.0
@export var max_lifetime: float:
	get: return _max_lifetime
	set(v):
		_max_lifetime = v
@export var hitbox: HitboxComponent

var _active: bool = false
var _lifetime_timer: float = 0.0
var _direction: Vector3 = Vector3.FORWARD

func _ready() -> void:
	if hitbox and not hitbox.area_entered.is_connected(_on_hitbox_entered):
		hitbox.area_entered.connect(_on_hitbox_entered)

func fire(start_pos: Vector3, dir: Vector3) -> void:
	global_position = start_pos
	_direction = dir.normalized()
	
	# Align projectile to face target direction
	if _direction != Vector3.ZERO and _direction.cross(Vector3.UP).length() > 0.01:
		look_at(global_position + _direction, Vector3.UP)
		
	_lifetime_timer = 0.0
	_active = true
	show()

func _physics_process(delta: float) -> void:
	if not _active: return
	
	# Manual timer avoids SceneTreeTimer garbage collection spikes
	_lifetime_timer += delta
	if _lifetime_timer >= max_lifetime:
		return_to_pool()
		return
		
	global_position += _direction * speed * delta

func _on_hitbox_entered(_area: Area3D) -> void:
	return_to_pool()

func return_to_pool() -> void:
	_active = false
	hide()
	returned_to_pool.emit(self)
