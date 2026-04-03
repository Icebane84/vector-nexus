extends CanvasLayer
@export var slot_prefab: PackedScene; @onready var grid = %ItemGrid
func refresh_ui(inventory: InventoryComponent):
	for c in grid.get_children(): c.queue_free()
	for item in inventory.items:
		var slot = slot_prefab.instantiate(); grid.add_child(slot); slot.display_item(item)
