extends Node
class_name CharacterStateMachine

@export var initial_state: State

@export var actor: CharacterBody3D
@export var anim: AnimationPlayer
@export var camera: PlayerCamera
@export var animation_tree: AnimationTree

var current_state: State

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
			child.actor = actor
			child.anim = anim
			child.camera = camera
			child.animation_tree = animation_tree
			child.hide()

	if initial_state:
		transition_to(initial_state)

func transition_to(target_state: State, msg: Dictionary = {}) -> void:
	if not target_state:
		return
	if target_state == current_state:
		return
	if current_state:
		current_state.exit()
		current_state.hide()
	current_state = target_state
	current_state.show()
	current_state.enter(msg)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.process_update(delta)

func get_current_state() -> State:
	return current_state

func get_state(state_name: String) -> State:
	for child in get_children():
		if child is State and child.name == state_name:
			return child
	return null