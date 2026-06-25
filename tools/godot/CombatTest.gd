# [GVRN]
# CombatTest.gd (v28.2)
# Purpose: Headless-safe combat logic verification.
extends SceneTree

func _init() -> void:
	print("--- PHOENIX_LOG: BEGINNING COMBAT TDD (RED PHASE) ---")
	
	# 1. Arrange: Create combat components
	var health := HealthComponent.new()
	health.max_health = 100.0
	health.current_health = health.max_health
	root.call_deferred(&"add_child", health)
	
	var hurtbox := HurtboxComponent.new()
	hurtbox.health_component = health
	root.call_deferred(&"add_child", hurtbox)
	
	var hitbox := HitboxComponent.new()
	hitbox.damage = 25.0
	hitbox.team_id = 99 # Different team
	root.call_deferred(&"add_child", hitbox)
	
	# Wait one frame for nodes to enter the tree and execute _ready()
	await process_frame
	
	var attack_data: Resource = load("res://scripts/resources/DATA.Combat.AttackData.gd").new() as Resource
	attack_data.damage = hitbox.damage
	attack_data.team_id = hitbox.team_id
	
	# 2. Act: Inflict Damage
	print("  [ACTION] Inflicting 25 damage...")
	hurtbox.receive_damage(attack_data)
	
	# 3. Assert (Expected: 75 HP)
	if health.current_health == 75.0:
		print("  [PASS] test_damage_application: Health correctly reduced.")
	else:
		print("  [FAIL] test_damage_application: Expected 75, got ", health.current_health)
 
	# 4. Act: Test I-Frames
	print("  [ACTION] Enabling I-frames and inflicting damage...")
	hurtbox.is_invincible = true
	hurtbox.receive_damage(attack_data)
	
	# 5. Assert (Expected: 75 HP - No additional damage)
	if health.current_health == 75.0:
		print("  [PASS] test_iframe_negation: Invincibility correctly blocked damage.")
	else:
		print("  [FAIL] test_iframe_negation: Damage leaked through I-frames.")
 
	print("--- PHOENIX_LOG: TDD COMPLETE ---")
	
	# Clean up nodes to prevent leaks
	health.free()
	hurtbox.free()
	hitbox.free()
	
	quit(0)
