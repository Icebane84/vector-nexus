extends CharacterBody3D
class_name Enemy

## PHOENIX ARCHITECT: ORCHESTRATOR PATTERN
## Root node responsible for physical movement and Dependency Injection.

@export_group("Dependencies")
@export var health_component: HealthComponent
@export var damage_text_pool: DamageTextPoolComponent

func _ready() -> void:
	_verify_dependencies()
	_bind_components()

func _verify_dependencies() -> void:
	assert(health_component != null, "Enemy: health_component is unassigned!")
	assert(damage_text_pool != null, "Enemy: damage_text_pool is unassigned!")

func _bind_components() -> void:
	# Rule III.1: Signals Up -> Calls Down
	# We route the health's damage signal directly into the text pool's display function.
	if not health_component.damaged.is_connected(damage_text_pool.display_damage):
		health_component.damaged.connect(damage_text_pool.display_damage)
	
	if not health_component.health_depleted.is_connected(_on_death):
		health_component.health_depleted.connect(_on_death)

func _on_death() -> void:
	# SKILL-004 Event Routing: Emit a death event, disable components, or transition state.
	queue_free()
