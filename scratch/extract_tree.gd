# scratch/extract_tree.gd
extends SceneTree

func _init() -> void:
	print("SOVEREIGN_LOG: Initializing tree_root extraction...")
	var scene := load("res://player/player_charbody3d.tscn") as PackedScene
	if not scene:
		printerr("SOVEREIGN_LOG: ERROR - Failed to load player scene")
		quit(1)
		return
		
	var inst := scene.instantiate() as Node
	if not inst:
		printerr("SOVEREIGN_LOG: ERROR - Failed to instantiate player scene")
		quit(1)
		return
		
	var anim_tree := inst.get_node_or_null("AnimStateTree") as AnimationTree
	if not anim_tree:
		printerr("SOVEREIGN_LOG: ERROR - Could not find AnimStateTree node")
		inst.free()
		quit(1)
		return
		
	var root_res := anim_tree.tree_root
	if not root_res:
		printerr("SOVEREIGN_LOG: ERROR - AnimationTree tree_root is null")
		inst.free()
		quit(1)
		return
		
	var err := ResourceSaver.save(root_res, "res://assets/Models/PlayerAnimTreeRoot.tres")
	if err != OK:
		printerr("SOVEREIGN_LOG: ERROR - Failed to save tree_root, code: ", err)
		inst.free()
		quit(1)
		return
		
	print("SOVEREIGN_LOG: Successfully saved AnimationTree tree_root to res://assets/Models/PlayerAnimTreeRoot.tres")
	inst.free()
	quit(0)
