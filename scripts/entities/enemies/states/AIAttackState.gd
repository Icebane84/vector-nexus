extends State
func enter():
	anim.play(&"attack")
	anim.animation_finished.connect(func(_n): transitioned.emit(ID.CHASE), CONNECT_ONE_SHOT)
