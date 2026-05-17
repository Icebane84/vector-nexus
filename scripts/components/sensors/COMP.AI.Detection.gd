# [GVRN]
# Artifact ID: COMP.AI.Detection
# Description: Standard awareness module for AI agents.
# Version: [SOVEREIGN]
# Author: Architect

extends Area3D

class_name DetectionComponent

signal target_acquired(target: Node3D)
signal target_lost

@export var target_group: StringName = &"player"
var _current_target: Node3D = null
func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node) -> void:
	if _current_target == null and body.is_in_group(target_group):
		_current_target = body as Node3D
		target_acquired.emit(_current_target)
func _on_body_exited(body: Node) -> void:
	if body == _current_target:
		_current_target = null
		target_lost.emit()
