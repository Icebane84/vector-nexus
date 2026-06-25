# scripts/entities/player/lib/Action.Transitions.gd
extends RefCounted

## PHOENIX: Action Transition Handler
## Manages state machine transitions and high-level animation requests.

static func check_standard_actions(state_machine: Node, stamina_comp: Node) -> bool:
    if not stamina_comp: return false
    
    var can_act: bool = (stamina_comp.current_stamina / stamina_comp.max_stamina) >= 0.1
    if not can_act: return false

    if Input.is_action_just_pressed(&"attack"):
        state_machine.transition_to(&"Attack")
        return true
    if Input.is_action_just_pressed(&"shadow_attack"):
        state_machine.transition_to(&"Attack")
        return true
    if Input.is_action_just_pressed(&"dodge") and stamina_comp.consume(25.0):
        state_machine.transition_to(&"Dodge")
        return true
    if Input.is_action_just_pressed(&"parry"):
        state_machine.transition_to(&"Parry")
        return true
    if Input.is_action_just_pressed(&"use_item"):
        state_machine.transition_to(&"UseItem")
        return true
    if Input.is_action_just_pressed(&"transform"):
        state_machine.transition_to(&"Transform", {"to_ugs": stamina_comp.get_parent().weapon_type != "UGS"})
        return true
        
    return false

static func play_state_animation(anim_tree: AnimationTree, anim_player: AnimationPlayer, anim_name: StringName) -> void:
    if anim_tree:
        var pb: AnimationNodeStateMachinePlayback = anim_tree.get(&"parameters/playback") as AnimationNodeStateMachinePlayback
        if pb: pb.travel(anim_name)

    elif anim_player and anim_player.has_animation(anim_name):
        anim_player.play(anim_name)
