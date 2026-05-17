# scripts/tools/lib/Audit.Infrastructure.gd
@tool
extends RefCounted

## PHOENIX: Infrastructure Auditor

static func check_autoloads() -> void:
	print("PHOENIX_LOG: Auditing Autoloads...")
	var required: Array[String] = ["_Director", "_GameEvents", "Log"]
	for a: String in required:
		if not ProjectSettings.has_setting("autoload/" + a):
			print("  [!] MISSING AUTOLOAD: ", a)
		else:
			print("  [+] Autoload found: ", a)

static func check_types() -> void:
	print("PHOENIX_LOG: Auditing Types (T)...")
	if ClassDB.class_exists("T") or ProjectSettings.has_setting("autoload/T"):
		print("  [+] Class 'T' recognized in global scope.")
	else:
		_fallback_types_check()

static func _fallback_types_check() -> void:
	var t_script: GDScript = load("res://scripts/globals/Types.gd") as GDScript
	if t_script:
		print("  [+] Types.gd loaded successfully.")
	else:
		print("  [!] ERROR: Types.gd NOT FOUND at res://Types.gd")
