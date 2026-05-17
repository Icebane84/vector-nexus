# [GVRN]
# Artifact ID: DATA.Quest.Objective
# Description: Data container for defining quest objectives.
# Author: Architect

extends Resource
class_name ObjectiveData

signal progress_updated(curr: int, total: int)
signal objective_completed

@export var description: String
@export var target_id: StringName
var _required_amount: int = 1
@export var required_amount: int:
	get: return _required_amount
	set(v):
		_required_amount = v
var _current_amount: int = 0
var current_amount: int:
	get: return _current_amount
	set(v):
		_current_amount = v
func increment(id: StringName) -> void:
	if id == target_id:
		current_amount = clampi(current_amount + 1, 0, required_amount)
		progress_updated.emit(current_amount, required_amount)
		if current_amount >= required_amount: objective_completed.emit()
