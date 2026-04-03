# res://scripts/systems/QuestManager.gd
extends Node

@export var active_quests: Array[QuestData] =[]

func _ready() -> void:
	Director.quest_system = self
	GameEvents.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(id: StringName) -> void:
	for q in active_quests:
		for o in q.objectives: 
			o.increment(id)
		q.check_completion()
