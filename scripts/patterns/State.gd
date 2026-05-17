"""
[GVRN]
Artifact ID: CORE.Pattern.State
Description: Base state class for the hierarchical state machine pattern.
Version: [SOVEREIGN]
Author: Architect
"""
extends Node
class_name PatternState

## PHOENIX ARCHITECT: SKILL-008 ALIGNMENT
## State class to be utilized by PatternStateMachine

var state_machine: Node # Untyped to avoid circularity with PatternStateMachine

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
