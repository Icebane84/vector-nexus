# [GVRN]
# Artifact ID: UI.Menu.Pause
# Description: A decoupled UI pause menu that reacts to Game State changes.
# Author: Architect

extends Control
class_name PauseMenuUI

@export var resume_button: Button
@export var quit_button: Button

func _ready() -> void:
	# Connect to the Universal Event Bus (SKILL-004)
	GameEvents.instance.game_state_changed.connect(_on_game_state_changed)
	if resume_button: resume_button.pressed.connect(_on_resume_pressed)
	if quit_button: quit_button.pressed.connect(_on_quit_pressed)
	hide() # Ensure the menu is invisible when the game boots up

func _on_game_state_changed(new_state: T.GameState) -> void:
	# We only become visible if the orchestrator decrees the game is paused
	visible = (new_state == T.GameState.PAUSED)

func _on_resume_pressed() -> void:
	GameEvents.instance.game_state_changed.emit(T.GameState.IN_GAME)

func _on_quit_pressed() -> void:
	get_tree().quit()
