extends Node
class_name SaveManager

signal game_saved(slot: int)
signal game_loaded(slot: int)

const SAVE_PATH = "user://saves/"
const PLAYER_DATA_KEY = "player"
const WORLD_DATA_KEY = "world"
const SCENE_KEY = "scene"
const PLAYER_REF = "res://entities/player/COMM.Avatar.Player.tscn"

const TIME_FUDGE = 1.0 / 120.0

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	print("SaveManager READY.")

func save_game(slot: int, engine_time: float, physics_time: float) -> void:
	var path := SAVE_PATH + "slot_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		printerr("SaveManager: Cannot open file for writing: ", path)
		return

	var now := Time.get_datetime_dict_from_system()
	var date_str := Time.get_datetime_string_from_dict(now, "en_US")

	var player := get_player()
	if not player:
		printerr("SaveManager: No player in scene!")
		return

	var save_data: Dictionary = {
		SCENE_KEY: get_tree().current_scene.scene_file_path,
		"timestamp": date_str,
		"player": player.save_game_data(),
		"physics_time": physics_time,
		"engine_time": engine_time,
		"world": {}
	}

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	save_game.emit(slot)
	print("SaveManager: Saved to slot %d. Engine: %.1fs, Physics: %.1fs" % [slot, engine_time, physics_time])

func _physics_process(delta: float) -> void:
	pass

func get_player() -> Player:
	# Find the player node.
	# In a real game you might have a singleton for the player or a manager.
	var root = get_tree().get_root()
	var player = root.find_child("Player", true)
	if player:
		return player as Player

	# Fallback: look for a CharacterBody3D named "Player"
	for node in get_tree().get_nodes_in_group("players"):
		if node is Player:
			return node

	return null

func load_game(slot: int) -> bool:
	var path := SAVE_PATH + "slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		printerr("SaveManager: File not found: ", path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("SaveManager: Cannot open file for reading: ", path)
		return false

	var content := file.get_as_text()
	file.close()

	var json_result := JSON.parse_string(content)
	if json_result == null:
		printerr("SaveManager: JSON parse error: ", JSON.get_error_message())
		return false

	var data := json_result as Dictionary
	if not data:
		printerr("SaveManager: Invalid save file format (not a dictionary)")
		return false

	var scene_path := data.get(SCENE_KEY)
	if typeof(scene_path) != TYPE_STRING:
		printerr("SaveManager: Invalid scene path in save data.")
		return false
	if not ResourceLoader.exists(scene_path):
		printerr("SaveManager: Scene not found: %s" % scene_path)
		return false
	var scene_res = load(scene_