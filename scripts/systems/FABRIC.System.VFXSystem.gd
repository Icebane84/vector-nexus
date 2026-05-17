# [GVRN]
# Artifact ID:   FABRIC.System.VFXSystem
# Description:   Unified kinetic feedback driver. Manages trauma, hit-stop, and impacts.
# Version:       [SOVEREIGN]
# Author:        Architect

extends Node

class_name VFXSystem

# Pattern 1: State/Trauma
var _trauma_decay: float = 0.8
@export var trauma_decay: float:
	get: return _trauma_decay
	set(v):
		_trauma_decay = v
var _trauma: float = 0.0 # 0.0 to 1.0

# Pattern 4: Object Pooling
@export var impact_vfx_scene: PackedScene
var _pool_size: int = 25
@export var pool_size: int:
	get: return _pool_size
	set(v):
		_pool_size = v

var _pool: Array[Node3D] = []
var _next_pool_idx: int = 0

func _ready() -> void:
	Log.wow(&"VFX", "Sovereign VFX System: ACTIVE")
	_initialize_pool()
	
	if GameEvents.instance:
		GameEvents.instance.impact_occurred.connect(_on_impact_occurred)
		GameEvents.instance.vfx_requested.connect(_on_vfx_requested)

func _on_impact_occurred(pos: Vector3, _dmg: float, _p_dmg: float) -> void:
	spawn_impact(pos)

func _on_vfx_requested(vfx_id: StringName, pos: Vector3, normal: Vector3) -> void:
	# Logic for different VFX IDs if needed
	spawn_impact(pos, normal)

func _process(delta: float) -> void:
	if _trauma > 0:
		_trauma = max(_trauma - trauma_decay * delta, 0)
		_apply_shake()

## --- Kinetic Feedback ---

func trigger_hit_stop(time_scale: float, duration: float) -> void:
	Engine.time_scale = time_scale
	Log.warn(&"VFX", "Hit-Stop Active: %0.2f Scale" % time_scale)
	
	# PHOENIX-FIX: Godot 4 create_timer parameters: (time_sec, process_always, process_idle, ignore_time_scale)
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func add_trauma(amount: float) -> void:
	_trauma = clamp(_trauma + amount, 0, 1.0)

func _apply_shake() -> void:
	var shake := _trauma * _trauma # Quadratic shake for better feel
	var cam := get_viewport().get_camera_3d()
	if cam:
		cam.h_offset = randf_range(-1.0, 1.0) * shake * 10.0
		cam.v_offset = randf_range(-1.0, 1.0) * shake * 10.0

## --- Impact Spawning (Pattern 4) ---

func _initialize_pool() -> void:
	if not impact_vfx_scene:
		impact_vfx_scene = load("res://scenes/vfx/DefaultVFX.tscn")
	
	if not impact_vfx_scene:
		Log.error(&"VFX", "Impact template missing! Fallback to Node3D.")
	
	for i in range(pool_size):
		var inst: Node3D
		if impact_vfx_scene:
			inst = impact_vfx_scene.instantiate() as Node3D
		else:
			inst = Node3D.new()
		add_child(inst)
		inst.hide()
		_pool.append(inst)

func spawn_impact(pos: Vector3, _normal: Vector3 = Vector3.UP) -> void:
	if _pool.is_empty(): return
	
	var inst := _pool[_next_pool_idx]
	inst.global_position = pos
	inst.show()
	
	if inst.has_method(&"play"):
		inst.call(&"play", pos)
	else:
		# Manual trigger for generic particle scenes
		for child in inst.find_children("*", "GPUParticles3D", true, false):
			(child as GPUParticles3D).emitting = true
		for child in inst.find_children("*", "CPUParticles3D", true, false):
			(child as CPUParticles3D).emitting = true
		get_tree().create_timer(2.0).timeout.connect(_on_timeout_triggered.bind(inst))
	
	_next_pool_idx = (_next_pool_idx + 1) % _pool.size()

# Alias for legacy calls
func spawn_vfx(pos: Vector3) -> void:
	spawn_impact(pos)

func _on_timeout_triggered(instance: Node3D) -> void:
	if is_instance_valid(instance): instance.hide()
