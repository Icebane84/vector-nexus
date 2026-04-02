extends ItemData
class_name EquipmentData
enum Slot { WEAPON, ARMOR }
@export var slot: Slot
@export var damage_modifier: float = 1.0
@export var visual_mesh: PackedScene