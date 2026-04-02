extends CharacterBody3D
class_name BossOrchestrator
@export var phases: Array[BossPhaseData] = []
var _phase_idx: int = 0
func _ready():
	$HealthComponent.health_changed.connect(_check_phase)
	$StateMachine.setup(self, $Visuals/AnimationPlayer)
func _check_phase(c, m):
	if _phase_idx < phases.size() and (c/m) <= phases[_phase_idx].hp_threshold:
		_apply_phase(phases[_phase_idx])
func _apply_phase(data):
	_phase_idx += 1
	$NavigationAgent3D.max_speed *= data.speed_mult
	$StateMachine.on_transition(State.ID.STAGGER)
	if $Visuals/AnimationPlayer.has_animation(data.phase_animation):
		$Visuals/AnimationPlayer.play(data.phase_animation)
func _physics_process(_d): move_and_slide()
