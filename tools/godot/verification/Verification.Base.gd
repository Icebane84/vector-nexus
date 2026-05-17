# [GVRN]
class_name VerificationSuite

## Abstract base class for verification suites.

var _success_count: int = 0
var _failure_count: int = 0

## SKILL-001: Backing-Field Resilience
var success_count: int:
	get: return _success_count
	set(v): _success_count = v

var failure_count: int:
	get: return _failure_count
	set(v): _failure_count = v

func run(_context: Dictionary) -> void:
	pass

func log_info(msg: String) -> void:
	print("  ", msg)

func log_ok(msg: String) -> void:
	print("  [OK] ", msg)
	_success_count += 1

func log_error(msg: String) -> void:
	print("  [ERROR] ", msg)
	_failure_count += 1

func log_critical(msg: String) -> void:
	print("  [CRITICAL ERROR] ", msg)
	_failure_count += 1

func log_skip(msg: String) -> void:
	print("  [SKIP] ", msg)
