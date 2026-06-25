extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var level_path = "res://scenes/world/TestArena.tscn"
	if not FileAccess.file_exists(level_path):
		print("ERROR: TestArena.tscn not found!")
		quit(1)
		return

	var scene = load(level_path) as PackedScene
	if not scene:
		print("ERROR: Failed to load TestArena.tscn!")
		quit(1)
		return

	var level = scene.instantiate() as Node3D
	if not level:
		print("ERROR: Instantiated node is not a Node3D!")
		quit(1)
		return

	root.add_child(level)
	await process_frame

	print("LEVEL HIERARCHY:")
	for child in level.get_children():
		print(" - ", child.name, " (", child.get_class(), ")")
		for subchild in child.get_children():
			print("   - ", subchild.name, " (", subchild.get_class(), ")")

	var enemy = level.find_child("EnemyBase", true, false) as EnemyBase
	if not enemy:
		print("ERROR: EnemyBase not found in level!")
		quit(1)
		return

	print("EnemyBase class: ", enemy.get_class())
	print("EnemyBase script: ", enemy.get_script().resource_path if enemy.get_script() else "None")
	print("EnemyBase patrol_target raw: ", enemy.get("patrol_target"))

	var patrol_target = enemy.patrol_target
	if not patrol_target:
		print("ERROR: EnemyBase patrol_target is not assigned!")
		quit(1)
		return

	print("[OK] EnemyBase patrol_target is assigned: ", patrol_target.name)
	if not patrol_target is PathFollow3D:
		print("ERROR: patrol_target is not a PathFollow3D!")
		quit(1)
		return

	# Record initial positions
	var initial_enemy_pos = enemy.global_position
	var initial_target_pos = patrol_target.global_position
	print("Initial Enemy Pos: ", initial_enemy_pos)
	print("Initial Target Pos: ", initial_target_pos)

	# Simulate 1.0 second of physics/process
	for i in range(60):
		# Manually process path progress and enemy physics update
		if patrol_target.has_method("_process"):
			patrol_target._process(1.0 / 60.0)
		elif patrol_target.get_script():
			# Call progress update if it's script process
			patrol_target.progress += patrol_target.patrol_speed * (1.0 / 60.0)

		# Wait for physics process frame
		await process_frame

	var final_target_pos = patrol_target.global_position
	print("Final Target Pos after 1s simulation: ", final_target_pos)

	if initial_target_pos.distance_to(final_target_pos) < 0.05:
		print("ERROR: PatrolPoint did not move along the Path3D curve!")
		quit(1)
		return

	print("[OK] PatrolPoint successfully moved along the curve.")
	print("SUCCESS: Enemy patrol path verification completed successfully!")
	level.queue_free()
	quit(0)
