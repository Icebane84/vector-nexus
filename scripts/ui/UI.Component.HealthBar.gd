extends ProgressBar # or TextureProgressBar



func _ready() -> void:
	# Connect to the global event bus instead of a direct reference (SKILL-004)
	# We use a strictly typed named method for connection safety (SKILL-005)
	if GameEvents.instance:
		GameEvents.instance.player_health_changed.connect(_on_player_health_changed)

# This function is triggered whenever the global health signal is emitted.
func _on_player_health_changed(new_health_value: float, max_health_value: float) -> void:
	self.max_value = max_health_value
	self.value = new_health_value
