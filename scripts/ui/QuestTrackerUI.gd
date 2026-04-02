extends VBoxContainer
@export var label_prefab: PackedScene
func _ready():
	Director.quest_system_ready.connect(func(mgr):
		for q in mgr.active_quests:
			for o in q.objectives:
				var lbl = label_prefab.instantiate(); add_child(lbl)
				o.progress_updated.connect(func(c, t): lbl.text = "%s: %d/%d" % [o.description, c, t]))