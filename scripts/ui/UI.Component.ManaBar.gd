extends ProgressBar # or TextureProgressBar

const Director = preload("res://scripts/globals/CORE.Kernel.Director.gd")
const GameEvents = preload("res://scripts/globals/CORE.Kernel.GameEvents.gd")

func _ready() -> void:
	# Connect to the global event bus instead of a direct reference (SKILL-004)
	# We still use a named method for connection safety (SKILL-005)
	if GameEvents.instance:
		GameEvents.instance.player_stamina_changed.connect(_on_player_mana_changed)

# 3. The named method that receives the signal's arguments
func _on_player_mana_changed(new_mana_value: float, max_mana_value: float) -> void:
	# Update the UI to reflect the new state
	max_value = max_mana_value
	value = new_mana_value
