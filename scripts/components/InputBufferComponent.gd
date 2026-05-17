"""
[GVRN]
Artifact ID: InputBufferComponent
Description: Centralized input buffering system.
"""

extends Node
class_name InputBufferComponent

# How long an input is remembered (in seconds)
var _buffer_window: float = 0.2 
@export var buffer_window: float:
	get: return _buffer_window
	set(v):
		_buffer_window = v

# Stores the action names and their remaining buffer time
var _buffered_actions: Dictionary = {}

func _process(delta: float) -> void:
	# Degrade the timers for all buffered actions
	var actions_to_remove: Array[String] = []

	for action in _buffered_actions.keys():
		_buffered_actions[action] -= delta
		if _buffered_actions[action] <= 0.0:
			actions_to_remove.append(action)
			
	# Clean up expired actions
	for action in actions_to_remove:
		_buffered_actions.erase(action)

## Call this from your main input handling script when a button is pressed
func buffer_action(action: String) -> void:
	_buffered_actions[action] = buffer_window

## Call this from your states to check if an action is queued up
func is_action_buffered(action: String) -> bool:
	return _buffered_actions.has(action)

## Call this when a state transitions to consume the input so it doesn't fire twice
func consume_action(action: String) -> void:
	if _buffered_actions.has(action):	_buffered_actions.erase(action)

## Optional: clear the whole buffer (useful when the player gets stunned/hit)
func clear_buffer() -> void:
	_buffered_actions.clear()
