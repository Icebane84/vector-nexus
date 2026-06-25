extends "res://scripts/components/state_machine/FABRIC.Logic.State.gd"
class_name PlayerTransformState

var _duration: float = 1.5
@export var duration: float:
	get: return _duration
	set(v):
		_duration = maxf(0.0, v)

var _timer: float = 0.0
var _to_ugs: bool = true

func enter(msg: Dictionary = {}) -> void:
	if not is_instance_valid(actor): return
	actor.velocity = Vector3.ZERO
	actor.busy = true
	
	_to_ugs = msg.get("to_ugs", true)
	_timer = duration
	
	# Emit weapon change started to trigger AnimationTree transition
	if actor.has_signal(&"weapon_change_started"):
		actor.weapon_change_started.emit()
	
	# Play transformation animation if available
	var anim_name: StringName = &"EnterShadowSelfParasiticTakeover" if _to_ugs else &"ExitShadowSelfParasiticTakeover"
	if animation_tree:
		var playback = animation_tree.get(&"parameters/playback") as AnimationNodeStateMachinePlayback
		if playback:
			playback.travel(anim_name)
	elif anim and anim.has_animation(anim_name):
		anim.play(anim_name)
	
	# Execute weapon swap halfway through the transition to hide the mesh pop
	var swap_delay: float = duration * 0.4
	var tween = actor.create_tween()
	tween.tween_callback(func():
		if is_instance_valid(actor) and actor.has_method(&"swap_weapon_meshes"):
			actor.swap_weapon_meshes(_to_ugs)
	).set_delay(swap_delay)

func exit() -> void:
	if is_instance_valid(actor):
		actor.busy = false

func physics_update(delta: float) -> void:
	if not is_instance_valid(actor): return
	_timer -= delta
	if _timer <= 0:
		state_machine.transition_to(&"Idle")
