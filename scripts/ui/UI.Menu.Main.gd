# [GVRN]
# Artifact ID: UI.Menu.Main
# Description: Decoupled Main Menu UI.
# Author: Architect

extends Control
class_name MainMenuUI

@export var start_button: Button
@export var quit_button: Button

func _ready() -> void:
	GameEvents.instance.game_state_changed.connect(_on_game_state_changed)
	if start_button: start_button.pressed.connect(_on_start_pressed)
	if quit_button: quit_button.pressed.connect(_on_quit_pressed)

func _on_game_state_changed(new_state: T.GameState) -> void:
	visible = (new_state == T.GameState.MAIN_MENU)

func _on_start_pressed() -> void:
	# Fade to black, wait for it to finish, then change the game state, then fade to clear!
	if has_node("/root/TransitionScreen"):
		await get_node("/root/TransitionScreen").fade_to_black()
	
	GameEvents.instance.game_state_changed.emit(T.GameState.IN_GAME)
	
	if has_node("/root/TransitionScreen"):
		get_node("/root/TransitionScreen").fade_to_clear()

func _on_quit_pressed() -> void:
	get_tree().quit()
