"""
[GVRN]
Artifact ID:   COMP.Stats.Sanity
Description:   Atomized psychological health tracker. Manages Sanity, Shadow Resonance,
               and emits strict signals for Instability cascade events.
"""
extends Node
class_name SanityComponent

# DAMP: Explicit descriptive signals
signal sanity_changed(current_sanity: float, maximum_sanity: float)
signal sanity_depleted()
signal instability_spike_triggered(instability_amount: float)

@export_group("Sanity Parameters")
var _maximum_sanity: float = 100.0
@export var maximum_sanity: float:
	get: return _maximum_sanity
	set(v):
		_maximum_sanity = v
var _passive_recovery_rate: float = 2.0
@export var passive_recovery_rate: float:
	get: return _passive_recovery_rate
	set(v):
		_passive_recovery_rate = v

@export_group("Shadow Resonance")
var _shadow_cost_multiplier: float = 1.5
@export var shadow_cost_multiplier: float:
	get: return _shadow_cost_multiplier
	set(v):
		_shadow_cost_multiplier = v

var _current_sanity: float = 0.0
var current_sanity: float:
	get: return _current_sanity
	set(v):
		_current_sanity = v
var _current_resonance: float = 0.0
var current_resonance: float:
	get: return _current_resonance
	set(v):
		_current_resonance = v

func _ready() -> void:
	_initialize_sanity()

func _initialize_sanity() -> void:
	current_sanity = maximum_sanity
	sanity_changed.emit(current_sanity, maximum_sanity)

func suffer_mental_damage(amount: float) -> void:
	if current_sanity <= 0:
		return
		
	current_sanity = clampf(current_sanity - amount, 0.0, maximum_sanity)
	sanity_changed.emit(current_sanity, maximum_sanity)
	
	if current_sanity <= 0.0:
		sanity_depleted.emit()

func heal_sanity(amount: float) -> void:
	current_sanity = clampf(current_sanity + amount, 0.0, maximum_sanity)
	sanity_changed.emit(current_sanity, maximum_sanity)

func consume_shadow_power(base_cost: float) -> void:
	# Using shadow power reduces sanity but also spikes instability.
	var total_cost: float = base_cost * shadow_cost_multiplier
	current_resonance += total_cost
	
	suffer_mental_damage(total_cost)
	instability_spike_triggered.emit(total_cost)
