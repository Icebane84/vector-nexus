extends Node

# The maximum mana a character can have.
var _max_mana: float = 100.0
@export var max_mana: float:
	get: return _max_mana
	set(v):
		_max_mana = v

# A signal to notify other nodes (like a UI bar) when mana has changed.
signal mana_changed(new_mana_value, max_mana_value)

# The private "backing field". It stores the true value of mana.
# The underscore prefix is a GDScript convention for private variables.
var _current_mana: float

# The public property that other scripts will interact with.
# We define custom 'get' and 'set' logic for it.
var current_mana: float:
	get:
		return _current_mana

	set(new_value):
		var clamped_value: float = clampf(new_value, 0.0, max_mana)

		if clamped_value != _current_mana:
			_current_mana = clamped_value
			mana_changed.emit(_current_mana, max_mana)
			# SKILL-004: Route the event through the global synapse
			GameEvents.instance.player_mana_changed.emit(_current_mana, max_mana)


### --- Usage Example ---

func _ready() -> void:
	# When the game starts, initialize mana to its maximum value.
	# This will automatically run the 'set' logic.
	current_mana = max_mana

func cast_spell(mana_cost: float) -> void:
	if current_mana >= mana_cost:
		# Subtracting from the property also triggers the 'set' logic,
		# ensuring the value is updated and the signal is emitted correctly.
		current_mana -= mana_cost
		print("Spell cast! Mana is now: ", current_mana)
	else:
		print("Not enough mana!")
