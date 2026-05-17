# [GVRN]
# Artifact ID:   CORE.System.SaveManager
# Description:   Persistence Layer for character state and world progress.
#                Sovereign Bridge: Fully decoupled from active systems.

extends Node
class_name SaveManager

const SAVE_PATH := "user://ashen_oath_save.dat"
const ENCRYPTION_KEY := "AO_SECURE_PHOENIX_2026"

signal save_completed
signal load_completed
signal save_error(message: String)

func _ready() -> void:
	# Sovereign Bridge: Fully decoupled.
	pass

func save_game(data: Dictionary) -> void:
	var file := FileAccess.open_encrypted_with_pass(
		SAVE_PATH,
		FileAccess.WRITE,
		ENCRYPTION_KEY
	)

	if file == null:
		save_error.emit("Could not open save file for writing.")
		return

	var json := JSON.stringify(data)
	file.store_string(json)
	file.close()

	save_completed.emit()
	Log.info("SaveManager", "Sovereign State Serialized.")

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open_encrypted_with_pass(
		SAVE_PATH,
		FileAccess.READ,
		ENCRYPTION_KEY
	)

	if file == null:
		save_error.emit("Could not open save file for reading.")
		return {}

	var json := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json)
	if parsed == null:
		save_error.emit("Could not parse save data.")
		return {}

	load_completed.emit()
	return parsed as Dictionary
