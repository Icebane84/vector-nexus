@tool
extends EditorPlugin

func _enter_tree() -> void:
	resource_saved.connect(_on_resource_saved)

func _exit_tree() -> void:
	resource_saved.disconnect(_on_resource_saved)

func _on_resource_saved(resource: Resource) -> void:
	# Only trigger if the saved file is a GDScript
	if resource is Script and resource.resource_path.get_extension() == "gd":
		# Convert Godot's internal res:// path to a standard Windows absolute path
		var script_path: String = ProjectSettings.globalize_path("res://tools/godot/generate_resonance_barrels.py")
		
		# Execute the python script natively in the background
		OS.execute("python", [script_path], [])
