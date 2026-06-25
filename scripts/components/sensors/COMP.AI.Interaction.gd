# [GVRN]
# Artifact ID: COMP.AI.Interaction
# Description: Standard raycast logic for player interaction with objects.
# Version: [SOVEREIGN]
# Author: Architect

extends RayCast3D

class_name InteractionsComponent

const LAYER_INTERACTABLE = 32 # Bit 5 (Layer 6)

@export var player: CharacterBody3D
var _interaction_distance: float = 3.0
@export var interaction_distance: float:
	get: return _interaction_distance
	set(v):
		_interaction_distance = v
		_update_ray_length()

func _ready() -> void:
	collision_mask = LAYER_INTERACTABLE
	_update_ray_length()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player): return
	
	# Position logic: Follow player height
	global_position = player.global_position + Vector3.UP
	
	# Update the raycast
	force_raycast_update()
	
	if is_colliding():
		var collider: Object = get_collider()
		var interactable: Node = _find_interactable(collider as Node)

		
		if interactable:
			_handle_ui_hint(interactable.interaction_text)
			if Input.is_action_just_pressed(&"interact"):
				interactable.interact(player)
		else:
			_hide_ui_hint()
	else:
		_hide_ui_hint()

func _update_ray_length() -> void:
	target_position = Vector3.FORWARD * interaction_distance

func _find_interactable(node: Node) -> Node:
	if not node:
		return null
	if node.has_method(&"interact"):
		return node
	# Look for the component in children to avoid tight coupling with node names
	for child in node.get_children():
		if child.has_method(&"interact"):
			return child
	return null

func _handle_ui_hint(text: String) -> void:
	# Use Global Synapse (SKILL-004) to notify HUD
	GameEvents.instance.interaction_hint_shown.emit(text)
	
func _hide_ui_hint() -> void:
	GameEvents.instance.interaction_hint_hidden.emit()
