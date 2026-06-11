"""
[GVRN] [UAM-V15]
Artifact ID:   COMM.Avatar.Player
Description:   Primary player character controller. 
               Orchestrates physics, states, and animation triggers.
Version:       2.0 [SOVEREIGN]
Relationships: GOVERNED_BY(Director), PROVIDES(CharacterState)
Status:        [CANONIZED]
"""

extends CharacterBody3D
class_name Player

# PHOENIX-GVRN: Explicit dependency resolution for headless stability (SKILL-007)
# Redundant preloads removed to avoid shadowing global classes
const StateMachineScript = preload("res://scripts/components/state_machine/FABRIC.Logic.StateMachine.gd")
const PlayerCameraScript = preload("res://scripts/entities/player/COMM.Avatar.PlayerCamera.gd")
const HealthComponentScript = preload("res://scripts/components/COMP.Physics.Health.gd")
const StaminaComponentScript = preload("res://scripts/components/COMP.Stats.Stamina.gd")
const HurtboxComponentScript = preload("res://scripts/components/COMP.Physics.Hurtbox.gd")
const HitboxComponentScript = preload("res://scripts/components/COMP.Physics.Hitbox.gd")
const PoiseComponentScript = preload("res://scripts/components/COMP.Stats.Poise.gd")
const SanityComponentScript = preload("res://scripts/components/COMP.Stats.Sanity.gd")
const ManifestationSystemScript = preload("res://scripts/systems/manifestation_system.gd")

# Input queuing system for input delay manifestation
class DelayedInput:
	var action: StringName
	var pressed: bool
	var time_left: float
	func _init(act: StringName, press: bool, delay: float):
		action = act
		pressed = press
		time_left = delay

const OathbringerScript = preload("res://scripts/entities/player/weapons/COMM.Weapon.Oathbringer.gd")

var manifestation_system: ManifestationSystemScript = ManifestationSystemScript.new()
var corruption_material: ShaderMaterial = null
var input_queue: Array[DelayedInput] = []
var action_states: Dictionary = {
	&"move_forward": false,
	&"move_back": false,
	&"move_left": false,
	&"move_right": false
}

var weapon_attachment: BoneAttachment3D = null
var weapon_mesh: Node3D = null

# --- Souls-like AnimTree Bindings & Signals ---
@warning_ignore("unused_signal")
signal dodge_started
@warning_ignore("unused_signal")
signal sprint_started
@warning_ignore("unused_signal")
signal landed_fall(hard_or_soft: String)
@warning_ignore("unused_signal")
signal jump_started
@warning_ignore("unused_signal")
signal interact_started(interact_type: String)
@warning_ignore("unused_signal")
signal climb_started
@warning_ignore("unused_signal")
signal weapon_change_started
@warning_ignore("unused_signal")
signal weapon_change_ended(weapon_type: String)
@warning_ignore("unused_signal")
signal attack_started
@warning_ignore("unused_signal")
signal gadget_change_started
@warning_ignore("unused_signal")
signal gadget_change_ended(gadget_type: String)
@warning_ignore("unused_signal")
signal gadget_started
@warning_ignore("unused_signal")
signal item_change_started
@warning_ignore("unused_signal")
signal item_change_ended(current_item: Resource)
@warning_ignore("unused_signal")
signal use_item_started
@warning_ignore("unused_signal")
signal parry_started
@warning_ignore("unused_signal")
signal hurt_started
@warning_ignore("unused_signal")
signal block_started
@warning_ignore("unused_signal")
signal death_started

enum SoulsState { FREE, STATIC, CLIMB }
var state: Dictionary = {
	"FREE": SoulsState.FREE,
	"STATIC": SoulsState.STATIC,
	"CLIMB": SoulsState.CLIMB
}
var current_state: SoulsState = SoulsState.FREE
var strafing: bool = false
var slowed: bool = false
var guarding: bool = false
var busy: bool = false
var weapon_type: String = "SLASH"
var gadget_type: String = "SHIELD"
var current_item: Resource = null
var _strafe_cross_product: float = 0.0
var strafe_cross_product: float:
	get: return _strafe_cross_product
	set(v):
		_strafe_cross_product = v
var _move_dot_product: float = 0.0
var move_dot_product: float:
	get: return _move_dot_product
	set(v):
		_move_dot_product = v
var input_dir: Vector2 = Vector2.ZERO

@export_group("Morality (The Kaelen Standard)")
@export_range(0.0, 1.0) var moral_alignment: float = 0.0

@export_group("Dependencies")
@export var state_machine: StateMachineScript # The StateMachine node
@export var camera: PlayerCameraScript
@export var visuals: Node3D
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var health_component: HealthComponentScript
@export var stamina_component: StaminaComponentScript
@export var hurtbox_component: HurtboxComponentScript
@export var hitbox_component: HitboxComponentScript
@export var poise_component: PoiseComponentScript
@export var sanity_component: SanityComponentScript

func _ready() -> void:
	assert(state_machine != null, "Player: state_machine is unassigned!")
	assert(animation_tree != null, "Player: animation_tree is unassigned!")
	assert(animation_player != null, "Player: animation_player is unassigned!")

	# Dynamic Souls-like AnimationTree & Library Injection
	if animation_tree:
		animation_tree.active = false
		var tree_root_res = load("res://assets/Models/PlayerAnimTreeRoot.tres") as AnimationNode
		if tree_root_res:
			animation_tree.tree_root = tree_root_res
			
	if animation_player:
		var melee_lib = load("res://assets/Models/MeleeLib.res") as AnimationLibrary
		if melee_lib:
			animation_player.add_animation_library(&"MeleeLib", melee_lib)

	if animation_tree:
		var anim_tree_script = load("res://scripts/entities/player/player_anim_tree.gd") as Script
		if anim_tree_script:
			animation_tree.set_script(anim_tree_script)
			animation_tree.set("player_node", self)
			if animation_tree.has_method("_ready"):
				animation_tree.call("_ready")
			animation_tree.active = true

	_setup_bridge()
	_weave_dependencies()
	_setup_corruption_shader()
	_setup_weapon()

	# Notify Global Synapse of instantiation
	GameEvents.instance.player_instantiated.emit(self)

func _setup_bridge() -> void:
	# BRIDGE-PATTERN: Routing local component signals to global synapse
	if health_component:
		health_component.health_changed.connect(
			func(cur: float, max_val: float): GameEvents.instance.player_health_changed.emit(cur, max_val)
		)
		health_component.died.connect(_on_death)

	if stamina_component:
		stamina_component.stamina_changed.connect(
			func(cur: float, max_val: float): GameEvents.instance.player_stamina_changed.emit(cur, max_val)
		)

	if camera:
		camera.target = self
		camera.target_locked.connect(
			func(t: Node3D): GameEvents.instance.lock_on_target_changed.emit(t)
		)

	if sanity_component:
		sanity_component.sanity_changed.connect(
			func(cur: float, max_val: float): GameEvents.instance.player_sanity_changed.emit(cur, max_val)
		)

	if hitbox_component:
		hitbox_component.hit_registered.connect(
			func(pos: Vector3, dmg: float, ps: float): GameEvents.instance.impact_occurred.emit(pos, dmg, ps)
		)

	if hurtbox_component:
		hurtbox_component.parry_successful.connect(
			func(_pos: Vector3): GameEvents.instance.parry_occurred.emit()
		)

	if poise_component and not poise_component.posture_broken.is_connected(_on_posture_broken):
		poise_component.posture_broken.connect(_on_posture_broken)

# --- Accessors for Decoupled Registration ---

func get_health_component() -> HealthComponentScript:
	return health_component

func get_stamina_component() -> StaminaComponentScript:
	return stamina_component

# --- Logic & Physics ---

func _weave_dependencies(parent: Node = null) -> void:
	if parent == null:
		parent = state_machine
	for child in parent.get_children():
		var state_node := child as State
		if not state_node:
			continue

		state_node.actor = self
		state_node.anim = animation_player
		state_node.camera = camera
		if "animation_tree" in state_node: state_node.set(&"animation_tree", animation_tree)

		# Reflection-based fallback for decoupled components
		if "hurtbox" in state_node: state_node.set(&"hurtbox", hurtbox_component)
		if "hitbox" in state_node: state_node.set(&"hitbox", hitbox_component)

		# Recurse for nested states
		_weave_dependencies(state_node)

func _on_posture_broken() -> void:
	if state_machine.has_method(&"transition_to"):
		state_machine.transition_to(&"Stagger")

func _physics_process(delta: float) -> void:
	# DEBUG: Morality Manipulation (The Kaelen Standard debug keys)
	if Input.is_key_pressed(KEY_T):
		update_alignment(-0.5 * delta) # Redeem over time
	if Input.is_key_pressed(KEY_G):
		update_alignment(0.5 * delta)  # Corrupt over time

	# Update instability manifestations
	var active_delay: bool = false
	if manifestation_system:
		var instability: float = 100.0 - sanity_component.current_sanity if sanity_component else 0.0
		manifestation_system.update(delta, instability)
		active_delay = manifestation_system.active_input_delay
		
		# Drive the sentient weapon's judgment state
		if weapon_mesh and weapon_mesh.has_method(&"judge_wielder"):
			weapon_mesh.judge_wielder(self)
			
		if corruption_material:
			corruption_material.set_shader_parameter(&"corruption_intensity", manifestation_system.current_distortion)
			
			# Kaelen: Dynamic Light/Dark Mode color palette interpolation
			var w: float = clamp((instability - 25.0) / 75.0, 0.0, 1.0)
			
			# Light Mode: Silver (#C0C0C0) and Gold (#D4AF37)
			var base_light := Color(0.753, 0.753, 0.753)
			var void_light := Color(0.831, 0.686, 0.216)
			
			# Dark Mode: Obsidian/Midnight Blue (#0D1B2A) and Crimson (#8B0000)
			var base_dark := Color(0.051, 0.106, 0.165)
			var void_dark := Color(0.545, 0.0, 0.0)
			
			corruption_material.set_shader_parameter(&"base_color", base_light.lerp(base_dark, w))
			corruption_material.set_shader_parameter(&"void_color", void_light.lerp(void_dark, w))

	# Process delayed actions
	var i: int = input_queue.size() - 1
	while i >= 0:
		var delayed: DelayedInput = input_queue[i]
		delayed.time_left -= delta
		if delayed.time_left <= 0:
			action_states[delayed.action] = delayed.pressed
			input_queue.remove_at(i)
		i -= 1

	# Gather immediate or queued inputs
	for action in action_states.keys():
		var pressed: bool = Input.is_action_pressed(action)
		if active_delay:
			# If the input state changed, queue it
			if pressed != action_states[action] and not _has_queued_action(action, pressed):
				input_queue.append(DelayedInput.new(action, pressed, 0.45)) # 450ms lag
		else:
			# Normal direct input mapping
			action_states[action] = pressed

	# Update guarding status based on whether parry input is held down
	guarding = Input.is_action_pressed(&"parry")

	# PHOENIX-GVRN: Central Gravity Management (SKILL-006)
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	move_and_slide()

func _has_queued_action(action: StringName, pressed: bool) -> bool:
	for delayed in input_queue:
		if delayed.action == action and delayed.pressed == pressed:
			return true
	return false

func get_movement_input() -> Vector2:
	return Vector2(
		float(action_states[&"move_right"]) - float(action_states[&"move_left"]),
		float(action_states[&"move_back"]) - float(action_states[&"move_forward"])
	)

func _setup_corruption_shader() -> void:
	var shader: Shader = load("res://assets/Shaders/SHD_Corruption.gdshader") as Shader
	if shader:
		corruption_material = ShaderMaterial.new()
		corruption_material.shader = shader
		if visuals:
			_apply_material_override(visuals, corruption_material)

func _apply_material_override(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_material_override(child, mat)

func _setup_weapon() -> void:
	var skeleton = _find_skeleton(visuals)
	if not skeleton:
		return
		
	# Create BoneAttachment3D (SKILL-014 dependency injection)
	weapon_attachment = BoneAttachment3D.new()
	weapon_attachment.name = &"WeaponAttachment"
	weapon_attachment.bone_name = &"DEF-hand.R"
	skeleton.add_child(weapon_attachment)
	
	# Instantiate Kaelen's Oathbringer sentient weapon (SKILL-022)
	weapon_mesh = Oathbringer.new()
	weapon_mesh.name = &"Oathbringer"
	weapon_attachment.add_child(weapon_mesh)
	
	# Wait for child ready initialization, then apply corruption shader override
	if corruption_material and weapon_mesh.get("sword_mesh") != null:
		var s_mesh = weapon_mesh.get("sword_mesh") as MeshInstance3D
		if s_mesh:
			s_mesh.material_override = corruption_material

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var res: Skeleton3D = _find_skeleton(child)
		if res:
			return res
	return null

# --- Sovereign Mechanics ---

## [SKILL-012] Decomposed Attack Logic
func execute_shadow_attack() -> void:
	if not sanity_component or sanity_component.current_sanity < 10.0:
		return

	# [Wisdom Scar]: VFX-First Animation Hack
	# We use a Ghost Mesh (VFX) and a Tween to sell the power without a custom anim.
	sanity_component.consume_shadow_power(15.0)

	# 1. Trigger VFX via Global Synapse
	var vfx_pos: Vector3 = global_position + global_transform.basis.z * -1.5
	GameEvents.instance.vfx_requested.emit(&"shadow_ghost", vfx_pos, Vector3.UP)

	# 2. Procedural Lunge
	var lunge_dir: Vector3 = -global_transform.basis.z
	var tween := create_tween()
	tween.tween_property(self, "velocity", lunge_dir * 20.0, 0.1)
	tween.tween_property(self, "velocity", Vector3.ZERO, 0.2).set_delay(0.1)

	# 3. Hit-Stop for "Weight"
	GameEvents.instance.impact_occurred.emit(global_position, 20.0, 50.0)

func _on_death() -> void:
	death_started.emit()
	set_physics_process(false)

func update_alignment(action_weight: float) -> void:
	moral_alignment = clampf(moral_alignment + action_weight, 0.0, 1.0)
	# Direct sync to sanity_component to drive all other instability logic seamlessly
	if sanity_component:
		sanity_component.current_sanity = (1.0 - moral_alignment) * sanity_component.max_sanity
