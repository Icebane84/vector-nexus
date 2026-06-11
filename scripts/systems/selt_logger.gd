# scripts/systems/selt_logger.gd
# @nexus GUCA.AOATH.SELT_LOGGER
class_name SeltLogger
extends RefCounted

static var logs: Array = []

static func log_event(event_type: String, rating: float, details: String) -> void:
	var entry = {
		"timestamp": Time.get_ticks_msec(),
		"event_type": event_type,
		"instability_rating": rating,
		"details": details
	}
	logs.append(entry)
	
	# Console printout mimicking Sovereign Audits
	print("[SELT LOG] [%d] Type: %s | Instability: %.1f%% | Info: %s" % [
		entry["timestamp"],
		entry["event_type"],
		entry["instability_rating"],
		entry["details"]
	])

static func get_logs() -> Array:
	return logs

static func clear_logs() -> void:
	logs.clear()
