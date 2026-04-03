extends RayCast3D
class_name InteractionsComponent
@export var player: Player
func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider.has_node("InteractableComponent"):
			var interactable = collider.get_node("InteractableComponent") as InteractableComponent
			_handle_ui_hint(interactable.interaction_text)
			if Input.is_action_just_pressed(&"interact"):
				interactable.interact(player)
	else:
		_hide_ui_hint()
func _handle_ui_hint(text: String):
	# Call up to HUD to show "Press E to Open"
	pass
func _hide_ui_hint():
	pass
