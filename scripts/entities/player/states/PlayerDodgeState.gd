extends State
class_name PlayerDodgeState
@export var speed: float = 16.0
@export var duration: float = 0.3
var hurtbox: HurtboxComponent
var _timer: float = 0.0
var _dir: Vector3
func enter():
	_timer = duration
	if hurtbox: hurtbox.is_invincible = true
	_dir = actor.velocity.normalized() if actor.velocity.length() > 0.1 else -actor.visuals.global_transform.basis.z
	anim.play(&"dodge", -1, 1.0 / duration)
func physics_update(delta):
	_timer -= delta
	actor.velocity.x = _dir.x * speed; actor.velocity.z = _dir.z * speed
	if _timer <= 0: transitioned.emit(ID.IDLE)
func exit(): if hurtbox: hurtbox.is_invincible = false