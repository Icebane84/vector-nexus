# res://scripts/ui/HUD.gd
extends CanvasLayer

func _ready() -> void:
	Director.player_health_ready.connect(_on_player_health_ready)

func _on_player_health_ready(node: HealthComponent) -> void:
	# Disconnect from any previous instances if necessary, then connect to the new one
	if not node.health_changed.is_connected(_on_health_changed):
		node.health_changed.connect(_on_health_changed)
		
	# Force update the UI immediately upon connection
	_on_health_changed(node.current_health, node.max_health)

func _on_health_changed(curr: float, max_v: float) -> void:
	%HealthBar.max_value = max_v
	%HealthBar.value = curr
