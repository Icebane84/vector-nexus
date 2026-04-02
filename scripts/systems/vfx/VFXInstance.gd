# res://scripts/systems/vfx/VFXInstance.gd
extends Node3D
class_name VFXInstance

var _active: bool = false
var _t: float = 0.0

func play(pos: Vector3) -> void:
	global_position = pos
	show()
	_active = true
	_t = 0.0
	# Access child node safely
	if has_node("Particles"):
		get_node("Particles").emitting = true

func _process(delta: float) -> void:
	if not _active: return
	_t += delta
	if _t >= 2.0:
		_active = false
		hide()
