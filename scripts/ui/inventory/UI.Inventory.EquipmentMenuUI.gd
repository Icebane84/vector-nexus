# [GVRN]
# Artifact ID: UI.Inventory.EquipmentMenuUI
# Description: Manages the equipment menu UI.
# Author: Architect

extends CanvasLayer

class_name EquipmentMenuUI

@export var slot_prefab: PackedScene

@onready var grid: Control = %ItemGrid as Control

func refresh_ui(inventory: InventoryComponent) -> void:
	for c in grid.get_children(): c.queue_free()
	for item in inventory.items:
		var slot: Node = slot_prefab.instantiate() as Node
		grid.add_child(slot)
		if slot.has_method("display_item"):
			slot.display_item(item)
