extends Node
var _p_health: HealthComponent
var player_health_component: HealthComponent:
	get: return _p_health
	set(v): _p_health = v; player_health_ready.emit(v)

var vfx_pool: Node
var audio_pool: Node
var active_combat_system: Node
var quest_system: Node
var save_manager: Node

# Make sure AttackData.gd exists and has 'class_name AttackData' inside it!
var combat_scratchpad: AttackData = AttackData.new()

signal player_health_ready(node: HealthComponent)
signal player_ready(player: Node)
signal quest_system_ready(mgr: Node)
