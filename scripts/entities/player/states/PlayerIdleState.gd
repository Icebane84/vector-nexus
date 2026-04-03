extends State
func enter(): anim.play(&"idle"); actor.velocity = Vector3.ZERO
func physics_update(_d):
	if Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back"): transitioned.emit(ID.MOVE)
	elif Input.is_action_just_pressed(&"attack"): transitioned.emit(ID.ATTACK)
