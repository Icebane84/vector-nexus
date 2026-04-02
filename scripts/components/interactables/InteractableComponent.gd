extends Node3D
class_name InteractableComponent
signal interacted(player: Player)
@export var interaction_text: String = "Interact"
@export var is_one_shot: bool = false
var _was_used: bool = false
func interact(player: Player) -> void:
	if is_one_shot and _was_used: return
	_was_used = true
	interacted.emit(player)