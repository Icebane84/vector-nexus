"""
[GVRN]
Artifact ID: CharacterState
Description: Base class for character states.
"""
extends Node

class_name CharacterState

# The entity this state is controlling. The StateMachine will inject this automatically.

var character: CharacterBody3D

## Called exactly once when the state machine enters this state.
func enter() -> void:
	pass

## Called exactly once when the state machine exits this state.
func exit() -> void:
	pass

## Called every frame. Good for standard visual updates or polling inputs.
func update(_delta: float) -> void:
	pass

## Called every physics frame. Good for movement, timers, and collision logic.
func physics_update(_delta: float) -> void:
	pass
