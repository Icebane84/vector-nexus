extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene_path = "res://scenes/entities/EnemyBase.tscn"
	if not FileAccess.file_exists(scene_path):
		print("ERROR: EnemyBase.tscn not found!")
		quit(1)
		return
		
	var scene = load(scene_path) as PackedScene
	if not scene:
		print("ERROR: Failed to load EnemyBase.tscn!")
		quit(1)
		return
		
	var enemy = scene.instantiate() as CharacterBody3D
	if not enemy:
		print("ERROR: Instantiated node is not a CharacterBody3D!")
		quit(1)
		return
		
	# Add to scene tree so _ready runs and AnimationPlayer is initialized
	root.add_child(enemy)
	
	# Wait one frame for _ready to execute
	await process_frame
	
	# Find skeleton and animation player
	var skeleton = enemy.find_child("GeneralSkeleton", true, false) as Skeleton3D
	var anim = enemy.anim as AnimationPlayer
	
	if not skeleton:
		print("ERROR: GeneralSkeleton not found in EnemyBase!")
		quit(1)
		return
		
	if not anim:
		print("ERROR: AnimationPlayer not found in EnemyBase!")
		quit(1)
		return
		
	# Get a bone to track (e.g., RightLowerArm or LeftUpperLeg)
	var bone_name = "RightLowerArm"
	var bone_idx = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		# Fallback to index 10 if RightLowerArm not found
		bone_idx = 10
		bone_name = skeleton.get_bone_name(bone_idx)
		
	var initial_pose = skeleton.get_bone_pose(bone_idx)
	print("Initial pose of bone '", bone_name, "': ", initial_pose)
	
	# Verify that the mapped animation 'move' is registered and has tracks
	if not anim.has_animation("move"):
		print("ERROR: Mapped animation 'move' is missing on the AnimationPlayer!")
		quit(1)
		return
		
	var anim_clip = anim.get_animation("move")
	print("Animation 'move' track count: ", anim_clip.get_track_count())
	if anim_clip.get_track_count() == 0:
		print("ERROR: Animation 'move' has 0 tracks!")
		quit(1)
		return
		
	print("First track path: ", anim_clip.track_get_path(0))
	
	# Play 'move' and advance time to simulate playback
	anim.play("move")
	anim.advance(0.2)
	
	# Force skeleton to update pose
	skeleton.force_update_all_bone_transforms()
	
	var new_pose = skeleton.get_bone_pose(bone_idx)
	print("Pose of bone '", bone_name, "' after 0.2s of 'move': ", new_pose)
	
	if initial_pose == new_pose:
		print("ERROR: Bone pose did not change! The animation tracks are not resolving or applying correctly!")
		quit(1)
	else:
		print("SUCCESS: Bone pose changed! Animations are playing and deforming the skeleton perfectly!")
		
	# Clean up
	enemy.queue_free()
	quit(0)
