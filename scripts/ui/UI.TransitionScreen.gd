# [GVRN]
# Artifact ID: UI.TransitionScreen
# Description: Global screen fader for state transitions.
extends CanvasLayer
class_name TransitionScreen

@export var fade_rect: ColorRect
var _fade_duration: float = 1.0
@export var fade_duration: float:
	get: return _fade_duration
	set(v):
		_fade_duration = v

func _ready() -> void:
	if fade_rect:
		fade_rect.modulate.a = 0.0
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Returns a Signal so we can 'await' it
func fade_to_black() -> Signal:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP # Block clicks while fading
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
	return tween.finished

func fade_to_clear() -> Signal:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_duration)
	tween.finished.connect(_on_finished_triggered)
	return tween.finished

func _on_finished_triggered() -> void:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
