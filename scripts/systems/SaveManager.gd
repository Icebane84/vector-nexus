extends Node
class_name SaveManager

const SAVE_PATH = "user://nexus_save.res"

func _ready():
	Director.save_manager = self

func save_game(data: Dictionary):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	print("PHOENIX_LOG: State Serialized to Disk.")

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return file.get_var()