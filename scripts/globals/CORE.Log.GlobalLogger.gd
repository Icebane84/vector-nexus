"""
[GVRN] [CORE] [LOG]
Artifact ID: CORE.Log.GlobalLogger
Version: v1.2 [SOVEREIGN]
Status: [CANONIZED]
Description: Global logging wrapper for the Ashen Oath.
"""

extends Node
class_name Log

static var active_system: Node = null

# Untyped helpers to ensure accessibility from any substrate layer
static func info(domain: Variant, msg: Variant) -> void:
	if active_system and active_system.has_method(&"log_message"):
		active_system.log_message(0, StringName(domain), str(msg)) # 0 = T.LogLevel.INFO
	else:
		if not Engine.is_editor_hint():
			print("[%s] INFO: %s" % [str(domain), str(msg)])

static func warn(domain: Variant, msg: Variant) -> void:
	if active_system and active_system.has_method(&"log_message"):
		active_system.log_message(1, StringName(domain), str(msg)) # 1 = T.LogLevel.WARN
	else:
		printerr("[%s] WARNING: %s" % [str(domain), str(msg)])

static func error(domain: Variant, msg: Variant) -> void:
	if active_system and active_system.has_method(&"log_message"):
		active_system.log_message(2, StringName(domain), str(msg)) # 2 = T.LogLevel.ERROR
	else:
		push_error("[%s] ERROR: %s" % [str(domain), str(msg)])

static func wow(domain: Variant, msg: Variant) -> void:
	if active_system and active_system.has_method(&"log_message"):
		active_system.log_message(3, StringName(domain), str(msg)) # 3 = T.LogLevel.WOW
	else:
		print("[%s] WOW: %s" % [str(domain), str(msg)])
