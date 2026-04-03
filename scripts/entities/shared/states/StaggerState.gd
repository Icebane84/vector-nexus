extends State
@export var duration: float = 0.8; var _timer: float = 0
func enter(): _timer = duration; actor.velocity = Vector3.ZERO; anim.play(&"stagger_hit")
func physics_update(delta):
	_timer -= delta; if _timer <= 0: transitioned.emit(ID.IDLE)
