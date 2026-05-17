"""
# [GVRN]
# Artifact ID: CORE.Pattern.EventBus
# Description: Global signal bus for decoupling and performance.
# Version: [SOVEREIGN]
# Author: Architect
"""
extends Node

## PHOENIX ARCHITECT: SKILL-GAM-001 ALIGNMENT
## Global signal bus for decoupling and performance.

# Player events
signal player_spawned(player: Node2D)
signal player_died(player: Node2D)
signal player_health_changed(health: int, max_health: int)

# Combat events
signal impact_registered(position: Vector2, force: float)
signal zone_entered(zone_id: StringName)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
