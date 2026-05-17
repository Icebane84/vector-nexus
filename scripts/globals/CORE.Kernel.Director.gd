"""
[GVRN] [UAM-V15]
Artifact ID:   CORE.Kernel.Director
Description:   The Coherence Kernel. Orchestrates high-level system initialization.
               Ensures all sovereign systems are awakened correctly.
Version:       2.0 [SOVEREIGN]
Status:        [CANONIZED]
"""

extends Node
class_name Director

static var instance: Director

# Kernel State
var player: Node3D
var active_systems: Dictionary = {}

func _init() -> void:
	instance = self

func _ready() -> void:
	Log.wow("DIRECTOR", "Kernel awakening in Sovereign Mode...")
	
	# 1. Awake the Global Synapse
	if GameEvents.instance:
		GameEvents.instance.core_awaken.emit()
		GameEvents.instance.player_instantiated.connect(_on_player_instantiated)

func _on_player_instantiated(p: Node3D) -> void:
	player = p
	Log.info("DIRECTOR", "Primary Avatar synchronized: " + p.name)

## Systemic Discovery (Optional helper)
func get_system(system_name: StringName) -> Node:
	return active_systems.get(system_name)

func register_system(system_name: StringName, node: Node) -> void:
	active_systems[system_name] = node
	Log.info("DIRECTOR", "System Registered: " + str(system_name))
