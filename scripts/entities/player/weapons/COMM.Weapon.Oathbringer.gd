# scripts/entities/player/weapons/COMM.Weapon.Oathbringer.gd
# [GVRN] [RNC: COMM.Weapon.Oathbringer]
# Description: Sentient Weapon Logic Core for Kaelen's Oathbringer.
#              Alters its visual mesh and emission light based on wielder corruption (instability).

class_name Oathbringer
extends Node3D

# ------------------------------------------------------------------------------
# CONSTANTS (The Laws of the Blade)
# ------------------------------------------------------------------------------

const CORRUPTION_THRESHOLD: float = 0.8
const MAX_CORRUPTION: float = 1.0
const MIN_CORRUPTION: float = 0.0

# Kaelen Color Scheme
const COLOR_PURE: Color = Color(0.0, 1.0, 0.84)    # Teal/Green-Gold mix (White Flame)
const COLOR_CORRUPT: Color = Color(0.545, 0.0, 0.0) # Blazing Crimson (Shadow)

# ------------------------------------------------------------------------------
# STATE VARIABLES
# ------------------------------------------------------------------------------

var _corruption_state: float = 0.0
var corruption_state: float:
	get: return _corruption_state
	set(v):
		_corruption_state = clampf(v, MIN_CORRUPTION, MAX_CORRUPTION)

var _emission_light: OmniLight3D
var sword_mesh: MeshInstance3D
var longsword_mesh: MeshInstance3D
var ugs_mesh: MeshInstance3D

# ------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------

func _ready() -> void:
	# Initialize the emission OmniLight3D
	_emission_light = OmniLight3D.new()
	add_child(_emission_light)
	_emission_light.light_energy = 1.0
	_emission_light.light_color = COLOR_PURE
	_emission_light.omni_range = 3.0

	# Only load template weapons scene if longsword_mesh is not pre-assigned
	if not longsword_mesh:
		var weapons_scene := load("res://assets/Models/templateweapons.glb") as PackedScene
		if weapons_scene:
			var weapons_inst := weapons_scene.instantiate() as Node3D
			if weapons_inst:
				var sword_node = weapons_inst.find_child("Sword", true, false)
				if sword_node and sword_node is MeshInstance3D:
					sword_mesh = MeshInstance3D.new()
					sword_mesh.name = &"SwordMesh"
					sword_mesh.mesh = sword_node.mesh
					# Align orientation for grip
					sword_mesh.transform = Transform3D(
						Basis(Vector3.UP, PI / 2.0) * Basis(Vector3.RIGHT, PI / 2.0),
						Vector3(-0.1, 0.2, 0.0)
					)
					add_child(sword_mesh)

# ------------------------------------------------------------------------------
# CORE LOGIC (The Judgment)
# ------------------------------------------------------------------------------

func judge_wielder(wielder: CharacterBody3D) -> float:
	var judgment_score: float = 0.0
	
	if "sanity_component" in wielder and wielder.get("sanity_component") != null:
		var sanity_comp = wielder.get("sanity_component")
		var current_sanity: float = sanity_comp.get("current_sanity")
		var max_sanity: float = sanity_comp.get("max_sanity") if "max_sanity" in sanity_comp else 100.0
		# Instability ratio from 0.0 (Pure) to 1.0 (Corrupt)
		judgment_score = clampf((max_sanity - current_sanity) / max_sanity, MIN_CORRUPTION, MAX_CORRUPTION)
	elif "moral_alignment" in wielder:
		var wielder_darkness: float = wielder.get("moral_alignment")
		judgment_score = clampf(wielder_darkness, MIN_CORRUPTION, MAX_CORRUPTION)
	else:
		# Default fallback
		judgment_score = 0.1
		
	_update_corruption_state(judgment_score)
	return judgment_score

func _update_corruption_state(new_state: float) -> void:
	corruption_state = clampf(new_state, MIN_CORRUPTION, MAX_CORRUPTION)
	
	if corruption_state > CORRUPTION_THRESHOLD:
		_trigger_void_consumption()

func _trigger_void_consumption() -> void:
	# Logic placeholder for wielder feedback
	printerr("[Oathbringer] WARNING: OATHBRINGER REJECTS WIELDER. VOID CONSUMPTION IMMINENT.")

# ------------------------------------------------------------------------------
# VISUAL PROCESS (The Pulse and Scale Morph)
# ------------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not _emission_light:
		return
		
	# Interpolate color based on corruption state
	var target_color: Color = COLOR_PURE.lerp(COLOR_CORRUPT, corruption_state)
	
	# Pulse effect using sine wave
	var time: float = Time.get_ticks_msec() / 1000.0
	var pulse: float = (sin(time * 2.0) + 1.0) * 0.5 # 0.0 to 1.0
	
	# If corrupt, pulse faster and more erratically
	if corruption_state > CORRUPTION_THRESHOLD:
		pulse = (sin(time * 10.0) + 1.0) * 0.5
		
	_emission_light.light_color = target_color
	_emission_light.light_energy = 1.0 + (pulse * 1.5)

	# Dynamic Weapon Scaling based on corruption (morphing longsword to greatsword)
	if longsword_mesh:
		var target_scale := Vector3.ONE.lerp(Vector3(1.4, 1.7, 1.4), corruption_state)
		longsword_mesh.scale = target_scale
	if ugs_mesh:
		var target_scale := Vector3.ONE.lerp(Vector3(1.4, 1.7, 1.4), corruption_state)
		ugs_mesh.scale = target_scale * 1.8 # Base UGS scale is 1.8x
	if sword_mesh:
		var target_scale := Vector3.ONE.lerp(Vector3(1.4, 1.7, 1.4), corruption_state)
		sword_mesh.scale = target_scale
