extends CanvasLayer
func _ready():
	Director.player_health_ready.connect(func(node):
		node.health_changed.connect(func(c, m): %HealthBar.max_value = m; %HealthBar.value = c)
	)