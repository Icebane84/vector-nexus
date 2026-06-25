# [GVRN]
# Artifact ID: COMM.Avatar.State.Attack
# Description: Standard melee attack state with buffered input and one-shot hitbox activation.

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerAttackState

const ActionLib = preload("res://scripts/entities/player/lib/Action.Transitions.gd")
const Orient = preload("res://scripts/entities/player/lib/Actor.Orientation.gd")

var _stamina_cost: float = 15.0
@export var stamina_cost: float:
	get(): return _stamina_cost
	set(v): _stamina_cost = v

var _damage: float = 20.0
@export var damage: float:
	get(): return _damage
	set(v): _damage = v

var _hit_delay: float = 0.25
@export var hit_delay: float:
	get(): return _hit_delay
	set(v): _hit_delay = v

var _state_duration: float = 0.6
@export var state_duration: float:
	get(): return _state_duration
	set(v): _state_duration = v

var _timer: float = 0.0
var _hit_landed: bool = false
var _buffered_input: bool = false
var _is_procedural_slashing: bool = false
var _combo_index: int = 0

var _swish_sounds: Array[AudioStream] = []

func _get_swish_sound() -> AudioStream:
	if _swish_sounds.is_empty():
		for i in range(1, 7):
			var path = "res://audio/SoundFX/swish/swish_%d.wav" % i
			var stream = load(path) as AudioStream
			if stream:
				_swish_sounds.append(stream)
	if _swish_sounds.is_empty():
		return null
	return _swish_sounds[randi() % _swish_sounds.size()]

func enter(_msg: Dictionary = {}) -> void:
	super.enter(_msg)
	_combo_index = _msg.get("combo_index", 0)
	_reset_state()

	if not _handle_stamina(): return

	var swish = _get_swish_sound()
	if swish and actor:
		GameEvents.instance.spatial_sound_requested.emit(swish, actor.global_position, 0.0, 0.1)

	if Input.is_action_just_pressed(&"shadow_attack"):
		if actor.has_method(&"execute_shadow_attack"):
			actor.execute_shadow_attack()
			state_machine.transition_to(&"Idle") # Return to idle after burst
			return

	if animation_tree and animation_tree.active:
		if "attack_count" in animation_tree:
			animation_tree.set(&"attack_count", _combo_index + 1)
		if actor and actor.has_signal(&"attack_started"):
			actor.attack_started.emit()
	else:
		# Dynamically check and play specific combo phase animation (attack_1, attack_2, attack_3) if they exist
		var target_anim := StringName("attack_%d" % (_combo_index + 1))
		if anim and anim.has_animation(target_anim):
			anim.play(target_anim)
		elif anim and anim.has_animation(&"attack"):
			anim.play(&"attack")
		else:
			_trigger_procedural_slash()

	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	Orient.orient_to_input(actor, camera, input)

func _reset_state() -> void:
	_timer = 0.0
	_hit_landed = false
	_buffered_input = false
	if _is_procedural_slashing:
		_is_procedural_slashing = false
		if actor and actor.visuals:
			actor.visuals.rotation.y = wrapf(actor.visuals.rotation.y, -PI, PI)
			actor.visuals.rotation.x = 0.0 # Reset pitch tilt

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
		# Dynamic Damage & Poise scaling for combo phases
		var active_damage := damage
		var active_poise := hitbox.poise_damage

		match _combo_index:
			0:
				active_damage = damage * 0.9      # Snappy opener
				active_poise = hitbox.poise_damage
			1:
				active_damage = damage * 1.0      # Medium follow-up
				active_poise = hitbox.poise_damage * 1.2
			2:
				active_damage = damage * 1.6      # Heavy overhead slam finisher!
				active_poise = hitbox.poise_damage * 2.2

		hitbox.damage = active_damage
		hitbox.poise_damage = active_poise
		hitbox.activate_one_shot()

		# Kinetic hit-stop / impact effect for the heavy finisher
		if _combo_index == 2:
			GameEvents.instance.impact_occurred.emit(actor.global_position, active_damage, active_poise)

		_hit_landed = true

func _process_input_buffer() -> void:
	if Input.is_action_just_pressed(&"attack"):
		_buffered_input = true

func _process_completion() -> void:
	if _timer >= state_duration:
		if _buffered_input:
			var next_combo: int = (_combo_index + 1) % 3
			state_machine.transition_to(&"Attack", { "combo_index": next_combo })
		else:
			state_machine.transition_to(&"Idle")

func exit() -> void:
	super.exit()
	_reset_state()

func _trigger_procedural_slash() -> void:
	_is_procedural_slashing = true

	if not actor or not actor.visuals:
		return

	var facing_dir := -actor.global_transform.basis.z
	facing_dir.y = 0.0
	facing_dir = facing_dir.normalized()

	var tween_rot := actor.create_tween().set_parallel(true)
	var tween_vel := actor.create_tween()

	match _combo_index:
		0: # Phase 0: Clockwise spin-slash + forward-right lunge
			var target_rot: float = actor.visuals.rotation.y + TAU
			tween_rot.tween_property(actor.visuals, "rotation:y", target_rot, 0.3)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)

			var lunge_dir := facing_dir.rotated(Vector3.UP, -PI / 8.0)
			actor.velocity = lunge_dir * 14.0
			tween_vel.tween_property(actor, "velocity", Vector3.ZERO, 0.25)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

		1: # Phase 1: Counter-clockwise spin-slash + forward-left lunge
			var target_rot: float = actor.visuals.rotation.y - TAU
			tween_rot.tween_property(actor.visuals, "rotation:y", target_rot, 0.3)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)

			var lunge_dir := facing_dir.rotated(Vector3.UP, PI / 8.0)
			actor.velocity = lunge_dir * 14.0
			tween_vel.tween_property(actor, "velocity", Vector3.ZERO, 0.25)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

		2: # Phase 2: Overhead leaping slam!
			# Spin visual 360 degrees
			var target_rot: float = actor.visuals.rotation.y + TAU
			tween_rot.tween_property(actor.visuals, "rotation:y", target_rot, 0.35)\
				.set_trans(Tween.TRANS_CUBIC)\
				.set_ease(Tween.EASE_OUT)

			# Pitch visual forward to represent overhead slam
			var original_rot_x: float = actor.visuals.rotation.x
			var tilt_tween := actor.create_tween()
			tilt_tween.tween_property(actor.visuals, "rotation:x", original_rot_x + PI / 6.0, 0.15)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
			tilt_tween.tween_property(actor.visuals, "rotation:x", original_rot_x, 0.2)\
				.set_trans(Tween.TRANS_BOUNCE)\
				.set_ease(Tween.EASE_OUT)

			# Vertical leap + forward lunge
			actor.velocity = facing_dir * 10.0 + Vector3.UP * 5.0

			# Sudden downward slam force
			tween_vel.tween_property(actor, "velocity", facing_dir * 12.0 + Vector3.DOWN * 8.0, 0.2)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)
			tween_vel.tween_property(actor, "velocity", Vector3.ZERO, 0.15)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)

func _freeze_movement() -> void:
	if not _is_procedural_slashing:
		super._freeze_movement()
