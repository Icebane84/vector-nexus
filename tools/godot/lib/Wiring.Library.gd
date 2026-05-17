# scripts/tools/lib/Wiring.Library.gd
extends RefCounted

## PHOENIX: Dependency Wiring Library

static func wire_player_core(player: Node) -> void:
	player.set("state_machine", player.get_node_or_null("StateMachine"))
	player.set("camera", player.get_node_or_null("CameraPivot/PlayerCamera"))
	player.set("visuals", player.get_node_or_null("Visuals"))

static func wire_player_combat(player: Node) -> void:
	player.set("health_component", player.get_node_or_null("HealthComponent"))
	player.set("stamina_component", player.get_node_or_null("StaminaComponent"))
	player.set("hurtbox_component", player.get_node_or_null("HurtboxComponent"))
	player.set("hitbox_component", player.get_node_or_null("HitboxComponent"))
	player.set("poise_component", player.get_node_or_null("PoiseComponent"))

static func wire_player_animation(player: Node) -> void:
	player.set("animation_tree", player.get_node_or_null("AnimationTree"))
	var anim_player: Node = player.find_child("AnimationPlayer", true, false)
	if anim_player:
		player.set("animation_player", anim_player)

static func wire_enemy_base(enemy: Node) -> void:
	enemy.set("state_machine", enemy.get_node_or_null("StateMachine"))
	enemy.set("nav_comp", enemy.get_node_or_null("NavigationComponent"))
	enemy.set("anim", enemy.get_node_or_null("Visuals/AnimationPlayer"))
	
	if enemy.has_node("DetectionComponent"):
		enemy.set("detection_component", enemy.get_node_or_null("DetectionComponent"))

static func wire_hud_menu(menu: Node, config: Dictionary) -> void:
	for key: String in config:
		var node: Node = menu.find_child(config[key], true, false)
		if node:
			menu.set(key, node)
