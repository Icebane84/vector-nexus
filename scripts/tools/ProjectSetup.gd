@tool
extends EditorScript
func _run():
	var layers = {1:"Environment", 2:"Player_Body", 3:"Enemy_Body", 4:"Player_Hitbox", 5:"Enemy_Hitbox", 6:"Interactables"}
	for i in layers: ProjectSettings.set_setting("layer_names/3d_physics/layer_" + str(i), layers[i])
	var actions = {"move_forward":[KEY_W], "move_back":[KEY_S], "attack":[MOUSE_BUTTON_LEFT]}
	for a in actions:
		if not ProjectSettings.has_setting("input/" + a):
			var ev = InputEventKey.new() if actions[a][0] > 10 else InputEventMouseButton.new()
			if ev is InputEventKey: ev.physical_keycode = actions[a][0]
			else: ev.button_index = actions[a][0]
			ProjectSettings.set_setting("input/" + a, {"deadzone":0.5, "events":[ev]})
	ProjectSettings.save()
	print("PHOENIX_LOG: Project Configured.")
