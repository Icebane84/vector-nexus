extends Node3D
class_name VFXInstance
var _active: bool = false; var _t: float = 0
func play(pos: Vector3): global_position = pos; show(); _active = true; _t = 0; $Particles.emitting = true
func _process(delta):
	if not _active: return
	_t += delta; if _t >= 2.0: _active = false; hide(); $Particles.emitting = false