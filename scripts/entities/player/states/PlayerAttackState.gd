extends State
class_name PlayerAttackState
enum Phase { STARTUP, ACTIVE, RECOVERY }
@export var startup_dur: float = 0.2
@export var active_dur: float = 0.15
@export var recovery_dur: float = 0.3
var _timer: float = 0.0
var _current_phase: Phase = Phase.STARTUP
var _buffer: bool = false
var hitbox: HitboxComponent
var poise_node: PoiseComponent
func enter():
	_current_phase = Phase.STARTUP; _timer = startup_dur; _buffer = false
	anim.play(&"attack_startup")
func exit():
	if hitbox: hitbox.set_deferred(&"monitoring", false)
	if poise_node: poise_node.is_hyper_armor_active = false
func physics_update(delta):
	_timer -= delta
	if Input.is_action_just_pressed(&"attack"): _buffer = true
	if _timer <= 0: _advance()
func _advance():
	match _current_phase:
		Phase.STARTUP:
			_current_phase = Phase.ACTIVE; _timer = active_dur
			if hitbox: hitbox.set_deferred(&"monitoring", true)
			if poise_node: poise_node.is_hyper_armor_active = true
			anim.play(&"attack_active")
		Phase.ACTIVE:
			_current_phase = Phase.RECOVERY; _timer = recovery_dur
			if hitbox: hitbox.set_deferred(&"monitoring", false)
			if poise_node: poise_node.is_hyper_armor_active = false
			anim.play(&"attack_recovery")
		Phase.RECOVERY:
			if _buffer: enter()
			else: transitioned.emit(ID.IDLE)
