extends SceneTree

func _init() -> void:
	var demo_lib_path: String = "C:/Users/Chris/Darksouls Like Starter Kit/Cats-Godot4-Modular-Souls-like-Template-main/player/animation_libraries/MeleeLib.res"
	var dest_path: String = "res://assets/Models/MeleeLib.res"
	
	if not FileAccess.file_exists(demo_lib_path):
		print("Demo animation library not found at: ", demo_lib_path)
		quit(1)
		return
		
	var demo_lib: AnimationLibrary = load(demo_lib_path) as AnimationLibrary
	if not demo_lib:
		print("Failed to load demo AnimationLibrary")
		quit(1)
		return
		
	var new_lib: AnimationLibrary = AnimationLibrary.new()
	var anim_list: Array[StringName] = demo_lib.get_animation_list()
	
	print("Starting extraction of ", anim_list.size(), " animations from demo MeleeLib.res...")
	
	for anim_name in anim_list:
		var src_anim: Animation = demo_lib.get_animation(anim_name)
		var anim: Animation = src_anim.duplicate() as Animation
		
		# Retarget tracks
		for i in range(anim.get_track_count()):
			var track_path: NodePath = anim.track_get_path(i)
			var path_str: String = str(track_path)
			var new_path_str: String = path_str
			
			if path_str.begins_with("%GeneralSkeleton:"):
				new_path_str = path_str.replace("%GeneralSkeleton:", "godot_rig/GeneralSkeleton:")
			elif path_str == "%GeneralSkeleton":
				new_path_str = "godot_rig/GeneralSkeleton"
				
			anim.track_set_path(i, NodePath(new_path_str))
			
		new_lib.add_animation(anim_name, anim)
		print("  Extracted and retargeted: ", anim_name)
		
	# Add fallback animations for missing references in AnimationTree
	if new_lib.has_animation(&"LandHard") and not new_lib.has_animation(&"LandSoft"):
		print("Creating LandSoft fallback from LandHard...")
		var land_soft = new_lib.get_animation(&"LandHard").duplicate()
		new_lib.add_animation(&"LandSoft", land_soft)
		
	if new_lib.has_animation(&"UsePotion") and not new_lib.has_animation(&"ItemUseFail"):
		print("Creating ItemUseFail fallback from UsePotion...")
		var item_use_fail = new_lib.get_animation(&"UsePotion").duplicate()
		new_lib.add_animation(&"ItemUseFail", item_use_fail)
		
	var err: Error = ResourceSaver.save(new_lib, dest_path)
	if err == OK:
		print("SUCCESS: Saved retargeted AnimationLibrary to ", dest_path)
		quit(0)
	else:
		print("ERROR: Failed to save AnimationLibrary, error code: ", err)
		quit(1)
