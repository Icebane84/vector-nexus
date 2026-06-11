# scripts/entities/enemies/COMM.Enemy.Whisperer.gd
# @nexus GUCA.AOATH.WHISPERER_AI
extends EnemyBase
class_name Whisperer

@export var proximity_range := 8.0
@export var sanity_drain_rate := 4.0

var whisper_timer := 0.0

func _ready() -> void:
	super._ready()
	# Locate target if unassigned
	if not target:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0] as Node3D

func _physics_process(delta: float) -> void:
	# Keep target updated if lost
	if not is_instance_valid(target):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0] as Node3D
			
	if is_instance_valid(target):
		# Proximity sanity drain check
		var distance := global_position.distance_to(target.global_position)
		if distance < proximity_range:
			_apply_sanity_drain(delta)
			
	super._physics_process(delta)

func _apply_sanity_drain(delta: float) -> void:
	var player_node = target as Player
	if not player_node: return
	
	var sanity_comp = player_node.sanity_component
	if sanity_comp:
		sanity_comp.suffer_mental_damage(sanity_drain_rate * delta)
		
		# Log to SeltLogger occasionally
		whisper_timer -= delta
		if whisper_timer <= 0.0:
			whisper_timer = randf_range(3.0, 6.0)
			var instability: float = 100.0 - sanity_comp.current_sanity
			SeltLogger.log_event(
				"WHISPERER_PROXIMITY",
				instability,
				"Whisperer proximity shadow is actively draining sanity!"
			)
