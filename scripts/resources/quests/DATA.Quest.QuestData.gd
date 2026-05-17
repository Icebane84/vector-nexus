# [GVRN]
# Artifact ID: DATA.Quest.QuestData
# Description: Data container for defining quests and objectives.
# Author: Architect

extends Resource
class_name QuestData

signal quest_completed

@export var title: String
@export var objectives: Array[ObjectiveData] = []

func check_completion() -> void:
	for o in objectives: if o.current_amount < o.required_amount: return
	quest_completed.emit()
