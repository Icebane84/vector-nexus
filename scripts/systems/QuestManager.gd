extends Node

@export var active_quests: Array[QuestData] = []
func _ready() -> void:
	Director.quest_system = self
	GameEvents.enemy_killed.connect(func(id):
		for q in active_quests:
			for o in q.objectives: o.increment(id)
			q.check_completion()
	)
	Director.quest_system_ready.emit(self)
