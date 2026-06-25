# [GVRN]
# Artifact ID: COMM.Enemy.PatrolPoint
# Description: Simple path-following patrol point node.

extends PathFollow3D
class_name PatrolPoint

@export var patrol_speed: float = 1.2

func _process(delta: float) -> void:
	progress += patrol_speed * delta
