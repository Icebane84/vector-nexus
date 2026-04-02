extends Node
class_name InventoryComponent
signal inventory_updated
@export var items: Array[ItemData] = []
func add_item(item: ItemData): items.append(item); inventory_updated.emit()