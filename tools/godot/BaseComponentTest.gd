# [GVRN]
# BaseComponentTest.gd
# Standardized base for PHOENIX-Pure unit tests
extends SceneTree

func assert_true(condition: bool, message: String) -> bool:
	if condition:
		print("  [PASS] %s" % message)
		return true
	else:
		print("  [FAIL] %s" % message)
		return false

func assert_eq(a: Variant, b: Variant, message: String) -> bool:
	if a == b:
		print("  [PASS] %s (%s == %s)" % [message, str(a), str(b)])
		return true
	else:
		print("  [FAIL] %s (Expected %s, got %s)" % [message, str(b), str(a)])
		return false

func assert_connected(signal_obj: Signal, target: Object, method: String, message: String) -> bool:
	if signal_obj.is_connected(Callable(target, method)):
		print("  [PASS] %s (Connected to %s)" % [message, method])
		return true
	else:
		print("  [FAIL] %s (Not connected to %s)" % [message, method])
		return false

func finish(success: bool) -> void:
	if success:
		print("--- PHOENIX_LOG: TEST SUITE PASSED ---")
		quit(0)
	else:
		print("--- PHOENIX_LOG: TEST SUITE FAILED ---")
		push_error("Test suite failed.")
		quit(1)
