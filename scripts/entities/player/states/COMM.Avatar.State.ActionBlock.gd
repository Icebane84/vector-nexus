# [GVRN]
# Artifact ID: COMM.Avatar.State.ActionBlock
# Description: Parent state for combat actions that pauses physics movement.
# Author: Architect

extends "res://scripts/components/state_machine/FABRIC.Logic.State.gd"
class_name PlayerActionBlockState


# const State = preload("res://scripts/components/state_machine/FABRIC.Logic.State.gd") # Shadowing


func enter(_msg: Dictionary = {}) -> void:
	# PHOENIX-GVRN: Physics execution paused during animation loops
	if actor:
		actor.velocity = Vector3.ZERO
		
	# SKILL-010: Input Buffering (Ghost-Proof Logic)
	# Check if we should immediately transition to a sub-action
	if _msg.has("target_action"):
		state_machine.transition_to(_msg.target_action)

func physics_update(_delta: float) -> void:
	# Default behavior for ActionBlocks is to prevent movement drift.
	# Subclasses like Dodge can override this if they manage their own velocity.
	_freeze_movement()

func _freeze_movement() -> void:
	if actor:
		actor.velocity.x = 0
		actor.velocity.z = 0
