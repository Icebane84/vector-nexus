# [GVRN]
# Artifact ID: COMM.Avatar.State.Attack
# Description: Standard melee attack state with buffered input and one-shot hitbox activation.

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerAttackState

const ActionLib = preload("res://scripts/entities/player/lib/Action.Transitions.gd")
const Orient = preload("res://scripts/entities/player/lib/Actor.Orientation.gd")

var _stamina_cost: float = 15.0
@export var stamina_cost: float:
	get: return _stamina_cost
	set(v): _stamina_cost = v

var _damage: float = 20.0
@export var damage: float:
	get: return _damage
	set(v): _damage = v

var _hit_delay: float = 0.25
@export var hit_delay: float:
	get: return _hit_delay
	set(v): _hit_delay = v

var _state_duration: float = 0.6
@export var state_duration: float:
	get: return _state_duration
	set(v): _state_duration = v

var _timer: float = 0.0
var _hit_landed: bool = false
var _buffered_input: bool = false

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_reset_state()
	
	if not _handle_stamina(): return
	
	if Input.is_action_just_pressed(&"shadow_attack"):
		if actor.has_method(&"execute_shadow_attack"):
			actor.execute_shadow_attack()
			state_machine.transition_to(&"Idle") # Return to idle after burst
			return

	ActionLib.play_state_animation(animation_tree, anim, &"attack")
	
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	Orient.orient_to_input(actor, camera, input)

func _reset_state() -> void:
	_timer = 0.0
	_hit_landed = false
	_buffered_input = false

func _handle_stamina() -> bool:
	if not actor.has_method(&"get_stamina_component"): return true
	var stamina: Node = actor.get_stamina_component()
	if stamina and not stamina.consume(stamina_cost):
		state_machine.transition_to(&"Idle")
		return false
	return true

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	_timer += delta
	_process_hitbox()
	_process_input_buffer()
	_process_completion()

func _process_hitbox() -> void:
	if not _hit_landed and _timer >= hit_delay and hitbox:
		hitbox.damage = damage
		hitbox.activate_one_shot()
		_hit_landed = true

func _process_input_buffer() -> void:
	if Input.is_action_just_pressed(&"attack"):
		_buffered_input = true

func _process_completion() -> void:
	if _timer >= state_duration:
		var next_state: StringName = &"Attack" if _buffered_input else &"Idle"
		state_machine.transition_to(next_state)

func exit() -> void:
	super.exit()
	_reset_state()
