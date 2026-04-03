extends Node
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal enemy_killed(id: StringName)
signal item_collected(id: StringName)
signal quest_objective_completed(quest_id: StringName, obj_idx: int)
signal save_triggered
signal load_triggered
