# [GVRN]
# Artifact ID: COMP.Inventory.Main
# Description: Standard item container and management hub.
# Author: Architect

extends Node

class_name InventoryComponent

signal inventory_updated

@export var items: Array[ItemData] = []

func _ready() -> void:
	if not GameEvents.instance.item_collected.is_connected(_on_item_collected):
		GameEvents.instance.item_collected.connect(_on_item_collected)

func _on_item_collected(item: ItemData) -> void:
	add_item(item)
	print("PHOENIX_LOG: Item stored in Inventory: ", item.display_name)

func add_item(item: ItemData) -> void:
	items.append(item)
	inventory_updated.emit()
