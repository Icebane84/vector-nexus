# [GVRN]
# Artifact ID: COMM.World.LootDrop
# Description: Physical item that can be picked up in the world.
# Author: Architect

extends RigidBody3D
class_name LootDrop

@export var item_data: ItemData
@export var interactable_component: InteractableComponent

func _ready() -> void:
	if interactable_component:
		interactable_component.interacted.connect(_on_interacted)

func _on_interacted(_player: Player) -> void:
	if item_data:
		GameEvents.instance.item_collected.emit(item_data)

		# Play collection sound
		var collect_sfx = load("res://audio/SoundFX/click/click_1.wav") as AudioStream
		if collect_sfx:
			GameEvents.instance.spatial_sound_requested.emit(collect_sfx, global_position, 0.0, 0.1)

		print("PHOENIX_LOG: Collected item: ", item_data.display_name)
	queue_free()
