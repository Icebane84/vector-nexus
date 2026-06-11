# [GVRN]
# Artifact ID:   FABRIC.System.AudioSystem
# Description:   The Aural Director. Manages spatial and static audio pools.
#                Sovereign Bridge: Communicates purely via GameEvents synapse.

extends Node
class_name AudioSystem

@export_group("Pool Settings")
var _spatial_pool_size: int = 16
@export var spatial_pool_size: int:
	get: return _spatial_pool_size
	set(v):
		_spatial_pool_size = v
@export var static_pool_size: int = 8

var _spatial_pool: Array[AudioStreamPlayer3D] = []
var _static_pool: Array[AudioStreamPlayer] = []
var _next_spatial: int = 0
var _next_static: int = 0

func _ready() -> void:
	Log.wow(&"AUDIO", "Sovereign Audio System: ACTIVE")
	_initialize_pools()
	
	if GameEvents.instance:
		GameEvents.instance.spatial_sound_requested.connect(play_spatial_sound)
		GameEvents.instance.aural_echo.connect(_on_aural_echo)

func _initialize_pools() -> void:
	for i in range(spatial_pool_size):
		var p := AudioStreamPlayer3D.new()
		p.bus = &"SFX"
		add_child(p)
		_spatial_pool.append(p)
		
	for i in range(static_pool_size):
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_static_pool.append(p)

func _on_aural_echo(type: String) -> void:
	if type == "neural_ping":
		Log.info("AUDIO", "Neural Ping synthesized.")

func play_spatial_sound(stream: AudioStream, position: Vector3, volume_db: float = 0.0, pitch_var: float = 0.1) -> void:
	if not stream or _spatial_pool.is_empty(): return
		
	var p := _spatial_pool[_next_spatial]
	p.stream = stream
	p.global_position = position
	p.volume_db = volume_db
	p.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var)
	p.play()
	
	_next_spatial = (_next_spatial + 1) % spatial_pool_size

func play_static_sound(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream or _static_pool.is_empty(): return
		
	var p := _static_pool[_next_static]
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = randf_range(0.95, 1.05)
	p.play()
	
	_next_static = (_next_static + 1) % static_pool_size
