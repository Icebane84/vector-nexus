# scripts/autoloads/SaveManager.gd
extends Node

const SAVE_PATH = "user://savegame.save"
const SaveRouter = preload("res://scripts/autoloads/lib/Save.Router.gd")

signal game_saved
signal game_loaded

func save_game() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		printerr("SaveManager: Failed to open save file.")
		return

	for node: Node in get_tree().get_nodes_in_group("Persist"):
		if node.has_method("save"):
			file.store_line(JSON.stringify(node.call("save")))
		else:
			printerr("SaveManager: Node '%s' lacks save()." % node.name)

	print("SaveManager: Game saved.")
	game_saved.emit()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: No save file found.")
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file: return

	while file.get_position() < file.get_length():
		_process_save_line(file.get_line())

	print("SaveManager: Game loaded.")
	game_loaded.emit()

func _process_save_line(line: String) -> void:
	var json: JSON = JSON.new()
	if json.parse(line) == OK:
		SaveRouter.route_data(get_tree(), json.get_data())
	else:
		printerr("SaveManager: JSON Parse Error: ", json.get_error_message())
