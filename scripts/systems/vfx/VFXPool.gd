extends Node
class_name VFXPool
@export var vfx_scene: PackedScene; var _pool: Array[VFXInstance] = []; var _next: int = 0
func _ready():
	Director.vfx_pool = self
	for i in range(25):
		var inst = vfx_scene.instantiate() as VFXInstance; add_child(inst); inst.hide(); _pool.append(inst)
func spawn_vfx(pos: Vector3):
	var inst = _pool[_next]; if not inst.visible: inst.play(pos); _next = (_next + 1) % _pool.size()