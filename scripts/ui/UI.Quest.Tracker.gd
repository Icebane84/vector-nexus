# [GVRN] [UAM-V15]
# Artifact ID:   UI.Quest.Tracker
# Description:   Visual Presentation Layer for active objectives.
#                Implements DAMP signal binding to avoid lambda leaks.
# Version:       1.1 [SOVEREIGN]
# Relationships: GOVERNED_BY(Director), CONSUMES(QuestManager)
# Status:        [CANONIZED]

extends VBoxContainer
class_name QuestTrackerUI

@export var label_prefab: PackedScene

func _ready() -> void:
	if GameEvents.instance:
		GameEvents.instance.quest_system_ready.connect(_on_quest_system_ready)

func _on_quest_system_ready(mgr: QuestManager) -> void:
	# Clear old tracker labels if scene reloaded
	for child in get_children():
		child.queue_free()

	for q in mgr.active_quests:
		for o in q.objectives:
			var lbl: Label = label_prefab.instantiate() as Label
			add_child(lbl)
			# Bind the specific label to the callback to avoid lambda leaks
			o.progress_updated.connect(_update_label.bind(lbl, o.description))
			_update_label(o.current_amount, o.required_amount, lbl, o.description)

func _update_label(curr: int, total: int, lbl: Label, desc: String) -> void:
	if is_instance_valid(lbl):
		lbl.text = "%s: %d/%d" %[desc, curr, total]
