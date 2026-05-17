# [GVRN]
# Artifact ID: DATA.Save.SaveData
# Description: Data container for saving and loading game state.
# Author: Architect

extends Resource
class_name SaveData

var _player_hp: float
@export var player_hp: float:
	get: return _player_hp
	set(v):
		_player_hp = v
@export var player_pos: Vector3
@export var inventory_paths: Array[String] = []
@export var quest_progress: Dictionary = {}
