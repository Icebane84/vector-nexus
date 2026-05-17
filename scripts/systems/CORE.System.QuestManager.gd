# [GVRN]
# Artifact ID:   CORE.System.QuestManager
# Description:   The Master Quest Engine. Tracks active objectives and state.
#                Sovereign Bridge: Communicates purely via GameEvents synapse.

extends Node
class_name QuestManager

var active_quests: Array = []

func _ready() -> void:
	# Sovereign Bridge: Fully decoupled.
	if GameEvents.instance:
		GameEvents.instance.enemy_killed.connect(_on_enemy_killed)
		GameEvents.instance.core_awaken.connect(_on_core_awaken)
		GameEvents.instance.quest_system_ready.emit(self)

func _on_core_awaken() -> void:
	Log.info("QuestManager", "Synchronizing quest state with Kernel...")
	# Initialize quests from save data or better: listen for a 'save_loaded' signal.

func _on_enemy_killed(enemy_id: StringName) -> void:
	Log.wow("QuestManager", "Processing death for Quest Logic: " + str(enemy_id))
	# Iterate active quests and update objectives here
	# Example:
	# for quest in active_quests:
	#     quest.process_kill(enemy_id)
