@tool
extends EditorScript

## PHOENIX_CODEX: v4.3.1 - Hardware Sanity Audit
func _run() -> void:
	print("--- PHOENIX_LOG: BEGINNING SYSTEM SANITY CHECK ---")
	
	# PHOENIX_FIX: EditorScript uses get_scene() to access the edited root
	var root = get_scene()
	
	if not root:
		print("PHOENIX_LOG: ERROR - No active scene open in the editor tab.")
		return

	# 1. Global Infrastructure Checks
	_check_autoloads()

	# 2. Context-Aware Audits
	# Note: We check class_name strings to avoid script-load circularity in the editor
	if root.name == "Main":
		_audit_main_scene(root)
	elif root.get_script() and root.get_script().get_global_name() == &"Player":
		_audit_player(root)
	elif root.get_script() and root.get_script().get_global_name() == &"EnemyBase":
		_audit_enemy(root)
	else:
		print("PHOENIX_LOG: Generic scene detected. Auditing children for common components...")
		_audit_generic(root)
	
	print("--- PHOENIX_LOG: SANITY CHECK COMPLETE ---")

func _check_autoloads() -> void:
	var required = ["Director", "GameEvents", "CombatDirector", "VfxPool"]
	for a in required:
		if not ProjectSettings.has_setting("autoload/" + a):
			print("  [!] MISSING AUTOLOAD: ", a)

func _audit_player(p: Node) -> void:
	print("PHOENIX_LOG: Auditing Player Instance...")
	if p.get("state_machine") == null: print("  [!] ERROR: Player 'state_machine' slot is empty.")
	if p.get("camera") == null: print("  [!] ERROR: Player 'camera' slot is empty.")
	
	_check_node(p, "HealthComponent")
	_check_node(p, "HurtboxComponent")
	_check_node(p, "HitboxComponent")

func _audit_enemy(e: Node) -> void:
	print("PHOENIX_LOG: Auditing Enemy Instance...")
	if e.get("state_machine") == null: print("  [!] ERROR: Enemy 'state_machine' slot is empty.")
	if e.get("nav_comp") == null: print("  [!] ERROR: Enemy 'nav_comp' slot is empty.")
	
	_check_node(e, "HealthComponent")

func _audit_main_scene(m: Node) -> void:
	print("PHOENIX_LOG: Auditing Main Test Chamber...")
	_check_node(m, "Player")
	_check_node(m, "EnemyBase")

func _audit_generic(n: Node) -> void:
	# Recursive check for any stray components
	for child in n.get_children():
		_audit_generic(child)

func _check_node(parent: Node, path: String) -> void:
	if not parent.has_node(path):
		print("  [!] MISSING NODE at path: ", path)
