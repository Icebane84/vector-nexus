# [GVRN]
# Main.gd
# Description: Root scene orchestrator. Manages game state and pausing.
extends Node3D

func _ready() -> void:
	# Critical: This ensures the Main script still listens to inputs while the game is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if not GameEvents.instance.game_state_changed.is_connected(_on_game_state_changed):
		GameEvents.instance.game_state_changed.connect(_on_game_state_changed)
	
	# Start the game
	GameEvents.instance.game_state_changed.emit(T.GameState.MAIN_MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var is_paused: bool = get_tree().paused
		var new_state: T.GameState = T.GameState.IN_GAME if is_paused else T.GameState.PAUSED
		GameEvents.instance.game_state_changed.emit(new_state)

func _on_game_state_changed(new_state: T.GameState) -> void:
	if new_state == T.GameState.IN_GAME:
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif new_state in [T.GameState.PAUSED, T.GameState.MAIN_MENU]:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
