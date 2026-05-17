# [GVRN]
extends SceneTree

# TDD Runner: LockOnSystem
# Goal: Test nearest viewport acquisition and right/left flicking.

func _init() -> void:
	print("--- TDD RED PHASE: LockOnSystem Test Started ---")
	
	# 1. Setup Mock Scene
	var root: Node3D = Node3D.new()
	var camera_node: Node3D = Node3D.new()
	var camera: Camera3D = Camera3D.new()
	camera_node.add_child(camera)
	camera.make_current()
	
	# Position camera at origin, looking backwards initially
	camera_node.position = Vector3(0, 0, 0)
	
	# Create LockOnComponent (will fail here initially since it doesn't exist)
	var lock_system: Node = load("res://scripts/components/COMP.Camera.LockOn.gd").new() as Node
	camera_node.add_child(lock_system)
	
	root.add_child(camera_node)
	
	# 2. Setup Mock Enemies
	var e1: Area3D = Area3D.new(); e1.position = Vector3(-5, 0, -10); e1.name = "Enemy_Left"
	var e2: Area3D = Area3D.new(); e2.position = Vector3(1, 0, -10); e2.name = "Enemy_Center"
	var e3: Area3D = Area3D.new(); e3.position = Vector3(6, 0, -10); e3.name = "Enemy_Right"
	
	root.add_child(e1); root.add_child(e2); root.add_child(e3)
	
	# Hack to bypass Area3D physics frames in headless unit test:
	# Inject mock targets manually into the component for testing purposes
	lock_system._mock_targets = [e1, e2, e3]
	
	# Wait for a frame to let 3D transforms update
	camera_node.force_update_transform()
	e1.force_update_transform(); e2.force_update_transform(); e3.force_update_transform()

	# 3. Test Viewport Center Acquisition
	print("Test 1: Find closest to center viewport")
	var target: Node3D = lock_system.find_closest_target(camera) as Node3D
	if target == e2:
		print("Test 1: PASSED")
	else:
		printerr("Test 1: FAILED. Expected ", e2.name, " got ", target.name if target else "null")
		
	# 4. Test Flick Right
	print("Test 2: Flick Right")
	lock_system.current_target = target
	var right_target: Node3D = lock_system.find_target_in_direction(camera, Vector2(1, 0)) as Node3D
	if right_target == e3:
		print("Test 2: PASSED")
	else:
		printerr("Test 2: FAILED. Expected ", e3.name, " got ", right_target.name if right_target else "null")

	# 5. Test Flick Left
	print("Test 3: Flick Left")
	lock_system.current_target = target
	var left_target: Node3D = lock_system.find_target_in_direction(camera, Vector2(-1, 0)) as Node3D
	if left_target == e1:
		print("Test 3: PASSED")
	else:
		printerr("Test 3: FAILED. Expected ", e1.name, " got ", left_target.name if left_target else "null")

	print("--- TDD RUN FINISHED ---")
	quit()
