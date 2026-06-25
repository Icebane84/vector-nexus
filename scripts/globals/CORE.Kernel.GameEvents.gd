"""
[GVRN] [UAM-V15]
Artifact ID:   CORE.Kernel.GameEvents
Description:   The Global Synapse. Orchestrates all high-frequency events.
Version:       1.2 [SOVEREIGN]
Relationships: GOVERNED_BY(Director)
Status:        [CANONIZED]
"""

@warning_ignore("unused_signal")
extends Node
class_name GameEvents
static var instance: GameEvents

func _init() -> void:
	instance = self

signal item_collected(item)
signal quest_objective_completed(quest_id, objective_id)
signal lock_on_target_changed(target)
signal enemy_killed(enemy_id: StringName)
signal player_instantiated(player: Node3D)
signal enemy_instantiated(enemy: Node3D)
signal impact_occurred(pos: Vector3, damage: float, poise_damage: float)
signal parry_occurred()

signal interaction_hint_shown(text: String)
signal interaction_hint_hidden()

signal spatial_sound_requested(stream: AudioStream, position: Vector3, volume_db: float, pitch_var: float)
signal vfx_requested(vfx_id: StringName, position: Vector3, normal: Vector3)
signal quest_system_ready(mgr: QuestManager)

# --- UI & Stat Signals ---
signal player_health_changed(current: float, maximum: float)
signal player_mana_changed(current: float, maximum: float)
signal player_stamina_changed(current: float, maximum: float)
signal player_sanity_changed(current: float, maximum: float)
signal player_active_item_changed(item: ItemData)

# --- Universal Event Bus ---
signal game_state_changed(new_state: int) # T.GameState
signal character_state_changed(actor: CharacterBody3D, new_state: int) # T.CharacterState
signal combat_state_changed(actor: Node3D, new_state: int) # T.CombatState

# --- Sovereign Signal Bus [PRS-002] ---
signal core_awaken
signal synergy_fire(payload: Dictionary)
signal coherence_ripple(intensity: float)
signal aural_echo(type: String)

# --- Locomotion Events [COMP.Locomotion] ---
## Emitted by FootstepAudioComponent when a foot contacts the ground.
## Consumers: VFX dust spawners, surface-type detectors.
signal footstep_occurred(position: Vector3, surface_normal: Vector3)
## Emitted by FootstepAudioComponent when a foot leaves the ground.
signal foot_lifted_occurred()
