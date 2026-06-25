# [GVRN]
# Artifact ID: COMP.World.Interactable
# Description: Standardized interaction interface for world objects.
# Version: [SOVEREIGN]
# Author: Architect

extends Area3D

class_name InteractableComponent

signal interacted(player: Player)

@export var interaction_text: String = "Interact"
@export var is_one_shot: bool = false

var _was_used: bool = false

func _ready() -> void:
	collision_layer = 32
	collision_mask = 0

func interact(player: Player) -> void:
	if is_one_shot and _was_used: return
	_was_used = true
	interacted.emit(player)
