extends Resource
class_name ObjectiveData
signal progress_updated(curr: int, total: int)
signal objective_completed
@export var description: String
@export var target_id: StringName
@export var required_amount: int = 1
var current_amount: int = 0
func increment(id: StringName) -> void:
	if id == target_id:
		current_amount = clampi(current_amount + 1, 0, required_amount)
		progress_updated.emit(current_amount, required_amount)
		if current_amount >= required_amount: objective_completed.emit()
