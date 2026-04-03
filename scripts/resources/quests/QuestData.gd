extends Resource
class_name QuestData
@export var title: String
@export var objectives: Array[ObjectiveData] = []
signal quest_completed
func check_completion() -> void:
	for o in objectives: if o.current_amount < o.required_amount: return
	quest_completed.emit()
