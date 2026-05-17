# [GVRN]
# Artifact ID: UI.Inventory.InventorySlotUI
# Description: Manages a single inventory slot UI.
# Author: Architect

extends Control

class_name InventorySlotUi

@export var slot_prefab: PackedScene

@onready var grid: Control = %ItemGrid as Control

func display_item(item: ItemData) -> void: 
	if item: 
		%Icon.texture = item.icon
