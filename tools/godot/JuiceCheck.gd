@tool
extends EditorScript

func _run() -> void:
	# Fallback verification (Testing that the bridge exists)
	if Director.instance.audio_pool:
		Log.wow(&"VERIFY", "Audio Pool Registered")
	else:
		Log.error(&"VERIFY", "Audio Pool ORPHANED")

	if Director.instance.vfx_pool:
		Log.wow(&"VERIFY", "VFX Pool Registered")
		# Testing Hit-Stop logic (Internal await verification)
		if Director.instance.active_combat_system:
			Director.instance.active_combat_system.trigger_hit_stop(0.1, 0.5)
	else:
		Log.error(&"VERIFY", "VFX Pool ORPHANED")
	
	print("SOVEREIGN_JUICE: Verification script complete.")
