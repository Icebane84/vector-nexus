extends Node
class_name State

@export var state_name: String
@export var state_machine: StateManager

@export var actor: CharacterBody3D
@export var anim: AnimationPlayer
@export var camera: PlayerCamera
@export var animation_tree: AnimationTree

func enter(msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func process_update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func show() -> void:
	set_process(true)
	set_physics_process(true)

func hide() -> void:
	set_process(false)
	set_physics_process(false)