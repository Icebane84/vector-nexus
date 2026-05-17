"""
[GVRN]
Artifact ID:   Tool.ProjectSetup
Description:   Project configuration script.
               Configures Physics Layers and Input Actions.
Author:        Architect
[GVRN: IGNORE SKILL-011]
"""

@tool
extends EditorScript

func _run() -> void:
	var layers: Dictionary = {1:"Environment", 2:"Player_Body", 3:"Enemy_Body", 4:"Player_Hitbox", 5:"Enemy_Hitbox", 6:"Interactables"}
	for i: int in layers: ProjectSettings.set_setting("layer_names/3d_physics/layer_" + str(i), layers[i])
	var actions: Dictionary = {"move_forward":[KEY_W], "move_back":[KEY_S], "attack":[MOUSE_BUTTON_LEFT]}
	for a: String in actions:
		if not ProjectSettings.has_setting("input/" + a):
			var ev: InputEvent = (InputEventKey.new() as InputEvent) if actions[a][0] > 10 else (InputEventMouseButton.new() as InputEvent)
			if ev is InputEventKey: (ev as InputEventKey).physical_keycode = actions[a][0]
			else: (ev as InputEventMouseButton).button_index = actions[a][0]
			ProjectSettings.set_setting("input/" + a, {"deadzone":0.5, "events":[ev]})

	ProjectSettings.save()
	print("PHOENIX_LOG: Project Configured.")
