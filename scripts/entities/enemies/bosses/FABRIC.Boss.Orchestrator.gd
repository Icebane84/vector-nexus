# [GVRN] [FABRIC] [BOSS]
# Artifact ID: FABRIC.Boss.Orchestrator
# Version: v2.0 [SOVEREIGN]
# Status: [CANONIZED]
# Description: Hierarchical behavior manager for multi-phase bosses.
#              Inherits Sovereign Bridge logic from EnemyBase.

extends EnemyBase
class_name BossOrchestrator

const BossPhaseData = preload("res://scripts/resources/ai/DATA.AI.BossPhase.gd")

@export_group("Boss Settings")
@export var phases: Array[BossPhaseData] = []

var _phase_idx: int = 0

func _ready() -> void:
	super._ready()
	
	if health_component:
		if not health_component.health_changed.is_connected(_check_phase):
			health_component.health_changed.connect(_check_phase)
	
	# Notify specifically for Boss HP bar systems if they exist
	# GameEvents.instance.boss_instantiated.emit(self)

func _check_phase(c: float, m: float) -> void:
	if _phase_idx < phases.size() and (c/m) <= phases[_phase_idx].hp_threshold:
		_apply_phase(phases[_phase_idx])

func _apply_phase(data: BossPhaseData) -> void:
	_phase_idx += 1
	
	# Navigation speed update
	if nav_comp and nav_comp.has_method("set_speed_mult"):
		nav_comp.set_speed_mult(data.speed_mult)
	elif get_node_or_null("NavigationAgent3D"):
		get_node("NavigationAgent3D").max_speed *= data.speed_mult
		
	if state_machine.has_method("transition_to"):
		state_machine.transition_to(&"Stagger")
		
	if anim and anim.has_animation(data.phase_animation):
		anim.play(data.phase_animation)

# Physics process is handled by EnemyBase
