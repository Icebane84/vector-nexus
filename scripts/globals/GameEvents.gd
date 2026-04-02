extends Node
signal player_died
signal enemy_killed(id: StringName)
signal item_collected(id: StringName)
signal quest_objective_completed(quest_id: StringName, obj_idx: int)
signal save_triggered
signal load_triggered
