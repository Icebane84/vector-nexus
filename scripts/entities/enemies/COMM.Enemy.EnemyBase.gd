"""
[GVRN] [COMM] [ENEMY]
Artifact ID:   COMM.Enemy.EnemyBase
Description:   Base class for all enemy entities.
               Orchestrates AI components and routes signals to global synapse.
Version:       2.0 [SOVEREIGN]
Relationships: GOVERNED_BY(Director), PROVIDES(AIControl)
Status:        [CANONIZED]
"""

extends CharacterBody3D
class_name EnemyBase

# PHOENIX-GVRN: Explicit preloads for architectural integrity
# Note: GameEvents is a global class_name – referenced directly, no preload needed
const HealthComponentScript = preload("res://scripts/components/COMP.Physics.Health.gd")
const PoiseComponentScript = preload("res://scripts/components/COMP.Stats.Poise.gd")
const HitboxComponentScript = preload("res://scripts/components/COMP.Physics.Hitbox.gd")
const HurtboxComponentScript = preload("res://scripts/components/COMP.Physics.Hurtbox.gd")

@export_group("Identity")
@export var enemy_id: StringName = &"generic_enemy"

@export_group("Dependencies")
@export var state_machine: Node # StateMachine node
@export var nav_comp: Node # NavigationComponent
@export var anim: AnimationPlayer
@export var detection_component: Node
@export var health_component: HealthComponentScript
@export var poise_component: PoiseComponentScript
@export var hitbox_component: HitboxComponentScript
@export var hurtbox_component: HurtboxComponentScript

var target: Node3D
@onready var visuals: Node3D = $Visuals

@export_group("Patrol")
@export var patrol_target_path: NodePath
var patrol_target: Node3D = null
@export var patrol_speed: float = 2.0

func _ready() -> void:
	assert(state_machine != null, "EnemyBase: state_machine is unassigned!")

	if not patrol_target_path.is_empty():
		patrol_target = get_node_or_null(patrol_target_path) as Node3D

	_setup_animations()
	_setup_bridge()
	_weave_dependencies()

	# Notify Global Synapse of instantiation
	GameEvents.instance.enemy_instantiated.emit(self)

func _setup_animations() -> void:
	if not anim: return
	
	# Load retargeted animation library from assets
	var melee_lib := load("res://assets/Models/MeleeLib.res") as AnimationLibrary
	if melee_lib:
		anim.add_animation_library(&"MeleeLib", melee_lib)
		
		# Ensure default library exists
		var default_lib: AnimationLibrary
		if anim.has_animation_library(&""):
			default_lib = anim.get_animation_library(&"")
		else:
			default_lib = AnimationLibrary.new()
			anim.add_animation_library(&"", default_lib)
			
		# Dynamically map aliases for simple AI states
		_alias_animation(melee_lib, &"LightIdle", default_lib, &"idle")
		_alias_animation(melee_lib, &"LightRunning", default_lib, &"move")
		_alias_animation(melee_lib, &"Slash1", default_lib, &"attack")
		_alias_animation(melee_lib, &"Hurt1", default_lib, &"hurt")
		_alias_animation(melee_lib, &"Die1", default_lib, &"death")

		# Force AnimationPlayer cache update in Godot 4 by removing and re-adding
		anim.remove_animation_library(&"")
		anim.add_animation_library(&"", default_lib)

func _alias_animation(src_lib: AnimationLibrary, src_name: StringName, dest_lib: AnimationLibrary, dest_name: StringName) -> void:
	if src_lib.has_animation(src_name):
		dest_lib.add_animation(dest_name, src_lib.get_animation(src_name))

func _setup_bridge() -> void:
	# BRIDGE-PATTERN: Routing local component signals to global synapse
	if health_component:
		if not health_component.died.is_connected(_on_death):
			health_component.died.connect(_on_death)

	if hitbox_component:
		hitbox_component.hit_registered.connect(
			func(pos: Vector3, dmg: float, ps: float): GameEvents.instance.impact_occurred.emit(pos, dmg, ps)
		)

	if detection_component:
		if detection_component.has_signal("target_acquired"):
			detection_component.target_acquired.connect(_on_target_acquired_triggered)
		if detection_component.has_signal("target_lost"):
			detection_component.target_lost.connect(_on_target_lost_triggered)

	if hurtbox_component:
		if not hurtbox_component.hit_received.is_connected(_on_hit_received):
			hurtbox_component.hit_received.connect(_on_hit_received)

func _on_hit_received(_attack) -> void:
	if health_component and health_component.current_health <= 0.0:
		return
	if state_machine and state_machine.has_method(&"transition_to"):
		state_machine.transition_to(&"Hurt")

func _on_death() -> void:
	# PHOENIX-GVRN: Clean teardown and global notification
	GameEvents.instance.enemy_killed.emit(enemy_id)

	# Trigger LootComponent if it exists
	var loot_comp = get_node_or_null("LootComponent")
	if loot_comp and loot_comp.has_method(&"spawn_loot"):
		loot_comp.spawn_loot()

	if state_machine.has_method("transition_to"):
		state_machine.transition_to(&"Death")
	else:
		queue_free()

# --- Accessors ---

func get_health_component() -> HealthComponentScript:
	return health_component

# --- Internal Logic ---

func _weave_dependencies(parent: Node = null) -> void:
	if parent == null:
		parent = state_machine

	for child in parent.get_children():
		if child.has_method("set"):
			child.set("actor", self)
			if anim:
				child.set("anim", anim)

		# Recurse for nested logic
		_weave_dependencies(child)

func _physics_process(_delta: float) -> void:
	# PHOENIX-GVRN: Central Gravity Management
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * _delta

	move_and_slide()

func _on_target_acquired_triggered(t):
	target = t

func _on_target_lost_triggered():
	target = null
