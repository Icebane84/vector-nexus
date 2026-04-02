extends Node
var _timer: float = 0.0
var _attacked: bool = false
var _release_timer: float = 0.0
var _awaiting_release: bool = false
func _physics_process(delta):
	_timer += delta
	if _awaiting_release:
		_release_timer -= delta
		if _release_timer <= 0: _release_action(&"attack"); _awaiting_release = false
	if _timer > 1.5 and not _attacked:
		_attacked = true; _press_action(&"attack"); _awaiting_release = true; _release_timer = 0.1
func _press_action(a): var ev = InputEventAction.new(); ev.action = a; ev.pressed = true; Input.parse_input_event(ev)
func _release_action(a): var ev = InputEventAction.new(); ev.action = a; ev.pressed = false; Input.parse_input_event(ev)