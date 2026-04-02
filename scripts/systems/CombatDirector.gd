extends Node

func _ready() -> void:
	Director.active_combat_system = self

func trigger_hit_stop(duration: float, time_scale: float = 0.05) -> void:
	Engine.time_scale = time_scale
	# create_timer signature: (time_sec, process_always, process_in_physics, ignore_time_scale)
	# Setting the 4th argument to 'true' makes the timer ignore our time_scale change.
	var timer := get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(func(): 
		Engine.time_scale = 1.0
	)
