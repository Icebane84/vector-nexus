"""
[GVRN] [CORE] [LOG]
Artifact ID: CORE.Log.GlobalLogger
Version: v1.1 [SOVEREIGN]
Status: [CANONIZED]
Description: Global logging wrapper for the Ashen Oath.
"""

extends Node
class_name Log

# Untyped helper to ensure accessibility from any substrate layer
func info(domain: Variant, msg: Variant) -> void:
	if not Engine.is_editor_hint():
		print("[%s] INFO: %s" % [str(domain), str(msg)])

func warn(domain: Variant, msg: Variant) -> void:
	printerr("[%s] WARNING: %s" % [str(domain), str(msg)])

func error(domain: Variant, msg: Variant) -> void:
	push_error("[%s] ERROR: %s" % [str(domain), str(msg)])

func wow(domain: Variant, msg: Variant) -> void:
	print("[%s] WOW: %s" % [str(domain), str(msg)])
