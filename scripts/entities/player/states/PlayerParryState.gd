extends State
@export var active_window: float = 0.2; var _timer: float = 0; var hurtbox: HurtboxComponent
func enter():
	_timer = active_window; hurtbox.is_parry_window = true
	hurtbox.parry_successful.connect(_on_parry, CONNECT_ONE_SHOT); anim.play(&"parry_active")
func physics_update(delta):
	_timer -= delta; if _timer <= 0: transitioned.emit(ID.IDLE)
func _on_parry(_pos): Director.active_combat_system.trigger_hit_stop(0.2, 0.01); transitioned.emit(ID.IDLE)
func exit(): hurtbox.is_parry_window = false
