extends "res://scripts/components/state_machine/FABRIC.Logic.State.gd"
class_name PlayerIdleState


# const State = preload("res://scripts/components/state_machine/FABRIC.Logic.State.gd") # Shadowing global class State


func enter(_msg: Dictionary = {}) -> void:
	if animation_tree:
		var playback: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback") as AnimationNodeStateMachinePlayback
		if playback: playback.travel(&"idle")
	elif anim and anim.has_animation(&"idle"):
		anim.play(&"idle")

	if actor: actor.velocity = Vector3.ZERO

func physics_update(_delta: float) -> void:
	if not is_instance_valid(actor): return

	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input.length() > 0:
		print("[Idle] Input detected: ", input)
	if not actor.is_on_floor():
		state_machine.transition_to(&"Fall")
		return

	if Input.is_action_just_pressed(&"jump"):
		state_machine.transition_to(&"Jump")
		return

	if input.length() > 0.1:
		state_machine.transition_to(&"Move")
		return

	if Input.is_action_just_pressed(&"attack"):
		state_machine.transition_to(&"Attack")
		return

	if Input.is_action_just_pressed(&"dodge"):
		if actor.has_method(&"get_stamina_component"):
			var stamina: Node = actor.get_stamina_component()
			if stamina and stamina.consume(25.0):
				state_machine.transition_to(&"Dodge")
				return

	if Input.is_action_just_pressed(&"parry"):
		state_machine.transition_to(&"Parry")
		return
