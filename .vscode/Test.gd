extends State
class_name NewState

# --- Core Methods ---

func enter(msg: Dictionary = {}, extra_data: Dictionary = {}) -> void:
	print("Entering NewState...")

func exit(reason: String = "") -> void:
	print("Exiting NewState...")

func physics_update(_delta: float) -> void:
	pass

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func _is_valid_transition(next_state_name: String) -> bool:
	match next_state_name:
		"NewState": return false # Infinite loop
		"AnotherState": return true
		"Exit": return true
		_: return false

# --- State-Specific Signals ---
# Define signals that are unique to this state's behavior.
# Use the `@signal` keyword (Godot 4.3+) for built-in signal management.


	
	
@signal is_ready

# Example: A signal emitted when the character performs a specific action.
@signal action_completed(action_type: String, result: Dictionary) 	

