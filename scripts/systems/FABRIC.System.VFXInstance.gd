# [GVRN]
# Artifact ID:   FABRIC.System.VFXInstance
# Description:   Individual pooled VFX logic. Handles lifecycle and despawn timing.
# Version:       [SOVEREIGN]
# Author:        Architect

extends Node3D

# SKILL-002: Zero-Allocation Pooling

var _lifetime: float = 2.0
@export var lifetime: float:
	get: return _lifetime
	set(v):
		_lifetime = v
var _timer: float = 0.0

func _physics_process(delta: float) -> void:
	if visible:
		_timer += delta
		if _timer >= lifetime:
			_despawn()

func restart() -> void:
	_timer = 0.0
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = true
			child.restart()

func _despawn() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = false
