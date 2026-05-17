# scripts/components/lib/Combat.Impact.gd
extends RefCounted

## PHOENIX: Combat Impact Library
## Centralizes impact logic and cinematic constants to keep systems <15 complexity.

# --- Constants ---
const HITSTOP_LIGHT: float = 0.08
const HITSTOP_MEDIUM: float = 0.12
const HITSTOP_HEAVY: float = 0.20
const HITSTOP_PARRY: float = 0.25

const TIMESCALE_FREEZE: float = 0.02
const TIMESCALE_HEAVY: float = 0.05

# --- Logic ---

static func get_hitstop_duration(damage: float, poise_damage: float) -> float:
	if poise_damage >= 50.0: return HITSTOP_HEAVY
	if damage >= 25.0: return HITSTOP_MEDIUM
	return HITSTOP_LIGHT

static func calculate_impact_force(attack_data: Resource) -> float:
	if not attack_data: return 0.0
	# [Wisdom Scar]: get() only takes 1 argument in GDScript 4.
	# Use a null-safe check: get the property, default to 10.0 if absent.
	var raw = attack_data.get(&"poise_damage")
	var poise: float = float(raw) if raw != null else 10.0
	return poise / 10.0

static func get_impact_vfx_type(damage: float) -> String:
	if damage >= 30.0: return "heavy_impact"
	return "light_impact"
