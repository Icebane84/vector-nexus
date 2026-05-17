@tool
extends EditorScript

func _run() -> void:
	# Test the fallback (non-system) logging first
	Log.info(&"TEST", "Verifying fallback logging...")
	Log.wow(&"TEST", "Wow factor check!")
	
	print("SOVEREIGN_LOG: Verification script complete.")
