# test_t.gd
extends SceneTree

func _init() -> void:
	print("SOVEREIGN_LOG: Testing T...")
	var state = T.GameState.IN_GAME
	print("SOVEREIGN_LOG: T.GameState.IN_GAME = ", state)
	quit()
