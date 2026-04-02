extends State
class_name PlayerMoveState
@export var speed: float = 7.0
var camera: PlayerCamera
func physics_update(delta):
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input.length() < 0.1: transitioned.emit(ID.IDLE); return
	var basis := camera.global_transform.basis
	var dir := (Vector3(basis.z.x, 0, basis.z.z) * input.y + Vector3(basis.x.x, 0, basis.x.z) * input.x).normalized()
	actor.velocity.x = move_toward(actor.velocity.x, dir.x * speed, 60.0 * delta)
	actor.velocity.z = move_toward(actor.velocity.z, dir.z * speed, 60.0 * delta)
	actor.velocity *= (1.0 - (1.0 - 0.98) * delta * 60.0)
	actor.visuals.look_at(actor.global_position + dir, Vector3.UP)
	if Input.is_action_just_pressed(&"attack"): transitioned.emit(ID.ATTACK)
	elif Input.is_action_just_pressed(&"dodge"): transitioned.emit(ID.DODGE)
	elif Input.is_action_just_pressed(&"parry"): transitioned.emit(ID.PARRY)
