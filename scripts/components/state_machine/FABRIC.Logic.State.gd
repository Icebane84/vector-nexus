# [GVRN]
# Artifact ID: FABRIC.Logic.State
# Description: Base state class for the hierarchical state machine.
# Version: [SOVEREIGN]
# Author: Architect

extends Node
class_name State


# const T = preload("res://scripts/globals/Types.gd") # Shadowing global class T

const PlayerCameraScript = preload("res://scripts/entities/player/COMM.Avatar.PlayerCamera.gd")
const HurtboxComponentScript = preload("res://scripts/components/COMP.Physics.Hurtbox.gd")
const HitboxComponentScript = preload("res://scripts/components/COMP.Physics.Hitbox.gd")

# Legacy Compatibility ID
@export var state_id: T.StateID

@warning_ignore("unused_signal")
signal transitioned (to: State, from: T.StateID)

# PHOENIX-GVRN: State registration handled by parent StateMachine
var state_machine: Node # Untyped to avoid circularity with class_name StateMachine

# Entity Pointers
var actor: CharacterBody3D
var anim: AnimationPlayer
var animation_tree: AnimationTree
var camera: PlayerCameraScript
var hurtbox: HurtboxComponentScript
var hitbox: HitboxComponentScript

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass
