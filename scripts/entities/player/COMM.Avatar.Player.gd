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
	assert(health_component != null, "Player: health_component is unassigned!")
	assert(stamina_component != null, "Player: stamina_component is unassigned!")
	
	_setup_bridge()
	_weave_dependencies()
	
	# Notify Global Synapse of instantiation
	GameEvents.instance.player_instantiated.emit(self)

func _setup_bridge() -> void:
	# BRIDGE-PATTERN: Routing local component signals to global synapse
	if health_component:
		health_component.health_changed.connect(
			func(cur: float, max_val: float): GameEvents.instance.player_health_changed.emit(cur, max_val)
		)
	
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
		var state := child as State
		if not state:
			continue
		
		state.actor = self
		state.anim = animation_player
		state.camera = camera
		if "animation_tree" in state: state.set(&"animation_tree", animation_tree)
		
		# Reflection-based fallback for decoupled components
		if "hurtbox" in state: state.set(&"hurtbox", hurtbox_component)
		if "hitbox" in state: state.set(&"hitbox", hitbox_component)
		
		# Recurse for nested states
		_weave_dependencies(state)

func _on_posture_broken() -> void:
	if state_machine.has_method(&"transition_to"):
		state_machine.transition_to(&"Stagger")

func _physics_process(delta: float) -> void:
	# PHOENIX-GVRN: Central Gravity Management (SKILL-006)
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	move_and_slide()

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
