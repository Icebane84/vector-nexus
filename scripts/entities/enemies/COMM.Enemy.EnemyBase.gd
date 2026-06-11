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

func _ready() -> void:
	assert(state_machine != null, "EnemyBase: state_machine is unassigned!")

	_setup_bridge()
	_weave_dependencies()

	# Notify Global Synapse of instantiation
	GameEvents.instance.enemy_instantiated.emit(self)

func _setup_bridge() -> void:
	# BRIDGE-PATTERN: Routing local component signals to global synapse
	if health_component:
		if not health_component.health_depleted.is_connected(_on_death):
			health_component.health_depleted.connect(_on_death)

	if hitbox_component:
		hitbox_component.hit_registered.connect(
			func(pos: Vector3, dmg: float, ps: float): GameEvents.instance.impact_occurred.emit(pos, dmg, ps)
		)

	if detection_component:
		if detection_component.has_signal("target_acquired"):
			detection_component.target_acquired.connect(_on_target_acquired_triggered)
		if detection_component.has_signal("target_lost"):
			detection_component.target_lost.connect(_on_target_lost_triggered)

func _on_death() -> void:
	# PHOENIX-GVRN: Clean teardown and global notification
	GameEvents.instance.enemy_killed.emit(enemy_id)

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
