extends RigidBody3D
class_name ItemObject

@export var target_group: String = "enemy"
@export_enum("HURT", "HEAL") var effect_type: String = "HEAL"
@export_enum("DRINK", "THROWN", "OTHER") var object_type: String = "DRINK"
@export var power: int = 1
@export var time_to_live: float = 2.0
@onready var area3d: Area3D = $Area3D

var player_node
var use_item: bool = false
signal touched_target

func _ready() -> void:
	freeze = true
	if area3d:
		area3d.monitoring = false
		if not area3d.body_entered.is_connected(_on_area_3d_body_entered):
			area3d.body_entered.connect(_on_area_3d_body_entered)

func activate() -> void:
	if area3d:
		area3d.monitoring = true
	top_level = true
	freeze = false
	use_item = true
	await get_tree().create_timer(time_to_live).timeout
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	touched_target.emit()
	if body.is_in_group(target_group):
		if effect_type == "HEAL":
			if body.has_method(&"get_health_component"):
				var hc = body.get_health_component()
				if hc:
					hc.heal(power)
			elif body.has_method(&"heal"):
				body.heal(power)
		elif effect_type == "HURT":
			# Find hurtbox or health component
			var hurtbox = body.find_child("HurtboxComponent", true, false)
			if hurtbox and hurtbox.has_method(&"receive_damage"):
				var attack = AttackData.new()
				attack.damage = power
				attack.poise_damage = power * 0.5
				attack.team_id = 0 # Player is team 0
				attack.attacker_pos = global_position
				hurtbox.receive_damage(attack)
			else:
				var hc = body.find_child("HealthComponent", true, false)
				if hc and hc.has_method(&"receive_damage"):
					hc.receive_damage(power)
