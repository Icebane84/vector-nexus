@tool
extends EditorPlugin

# PHOENIX ARCHITECT (v1.0)
# Real-time Governance Bridge for Ashen Oath
# [Wisdom Scar]: GDScript mandates TABS for indentation, not spaces.
# This plugin uses tabs throughout and checks for SPACES as the violation.

func _enter_tree() -> void:
	print("--- PHOENIX_LOG: ARCHITECT ACTIVE ---")
	resource_saved.connect(_on_resource_saved)

func _exit_tree() -> void:
	print("--- PHOENIX_LOG: ARCHITECT STANDBY ---")
	if resource_saved.is_connected(_on_resource_saved):
		resource_saved.disconnect(_on_resource_saved)

func _on_resource_saved(resource: Resource) -> void:
	if resource is GDScript:
		_perform_governance_audit(resource as GDScript)

func _perform_governance_audit(gdscript_res: GDScript) -> void:
	var path: String = gdscript_res.resource_path

	# Skip tool scripts and addons — they are exempt from in-game mandates
	if path.begins_with("res://addons/") or path.begins_with("res://tools/"):
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return

	var content: String = file.get_as_text()
	file.close()

	var violations: Array = []

	# [Wisdom Scar — E1/E3]: GDScript requires TABS. Mixed-space indentation
	# causes parse errors. Flag files that use 4-space indented function bodies.
	# We check for lines starting with 4 spaces (common mixing pattern).
	for line in content.split("\n"):
		if line.begins_with("    ") and not line.begins_with("\t"):
			violations.append("Indentation Dissonance (space-indent detected — use tabs)")
			break  # One report per file is enough

	# Mandate: Sovereign-001 (No get_parent for dependency access)
	if ".get_parent()" in content:
		violations.append("SOVEREIGN-001 Violation (get_parent() detected — use injected references)")

	# Mandate: Skill-006 (Surface Awareness - Magic Collision Numbers)
	if "collision_mask =" in content and not "LAYER_" in content:
		violations.append("SKILL-006 Violation (Magic collision_mask number — define a named constant)")

	if violations.size() > 0:
		printerr("--- PHOENIX GOVERNANCE ALERT: %s ---" % path)
		for v in violations:
			printerr("  [!] %s" % v)
	else:
		print("--- PHOENIX_LOG: %s is PHOENIX-PURE ---" % path)
