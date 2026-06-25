extends SceneTree

func _init() -> void:
	var lib_path = "res://assets/Models/MeleeLib.res"
	if not FileAccess.file_exists(lib_path):
		print("ERROR: MeleeLib.res not found!")
		quit(1)
		return
		
	var lib = load(lib_path) as AnimationLibrary
	if not lib:
		print("ERROR: Failed to load MeleeLib.res!")
		quit(1)
		return
		
	var anims = lib.get_animation_list()
	print("MeleeLib.res contains ", anims.size(), " animations:")
	for anim_name in anims:
		print("  - ", anim_name)
	
	# Verify specific animation names we alias
	var check_list = [&"LightIdle", &"LightRunning", &"Slash1", &"Hurt1", &"Die1", &"UsePotion"]
	print("\nVerifying alias animations:")
	for name in check_list:
		if lib.has_animation(name):
			print("  [+] ", name, " exists")
		else:
			print("  [x] ERROR: ", name, " IS MISSING!")
			
	quit(0)
