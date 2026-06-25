# [GVRN]
# Artifact ID: COMM.Avatar.State.UseItem
# Description: Player item consumption state (e.g., Estus/Potion drinking).
# Author: Architect

extends "res://scripts/entities/player/states/COMM.Avatar.State.ActionBlock.gd"
class_name PlayerUseItemState

const ConsumableItemScript = preload("res://scripts/resources/items/DATA.Inventory.ConsumableItem.gd")

var _timer: float = 0.0
const STATE_DURATION: float = 1.2
const HEAL_DELAY: float = 0.6
var _healed: bool = false
var _heal_amount: float = 40.0

func enter(_msg: Dictionary = {}) -> void:
	if not actor or not actor.current_item or actor.current_item.count <= 0:
		state_machine.transition_to(&"Idle")
		return
		
	super.enter(_msg)
	_timer = 0.0
	_healed = false
	
	if actor.has_signal(&"use_item_started"):
		actor.use_item_started.emit()

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	_timer += delta
	
	# Trigger heal/throw effect halfway through the animation
	if not _healed and _timer >= HEAL_DELAY:
		_healed = true
		if actor and actor.current_item and actor.current_item.count > 0:
			var item = actor.current_item as ConsumableItemScript
			if item.consumable_type == 0: # HEAL
				var health = actor.get_health_component()
				if health:
					var healed_amt = health.heal(item.potency)
					print("[PlayerUseItemState] Healed: ", healed_amt)
			elif item.consumable_type == 1: # DAMAGE (Thrown)
				if item.physical_instance:
					var inst = item.physical_instance.instantiate() as RigidBody3D
					inst.set(&"player_node", actor)
					inst.set(&"target_group", "enemy")
					inst.set(&"power", item.potency)
					
					# Add to weapon attachment (hand bone)
					if actor.weapon_attachment:
						actor.weapon_attachment.add_child(inst)
					else:
						actor.add_child(inst)
						
					inst.call(&"activate")
					var throw_dir = -actor.visuals.global_transform.basis.z.normalized()
					throw_dir.y += 0.2
					throw_dir = throw_dir.normalized()
					inst.apply_impulse(throw_dir * 15.0)
					print("[PlayerUseItemState] Threw item: ", item.display_name)
					
			item.count -= 1
			# Emit update signals
			GameEvents.instance.player_active_item_changed.emit(item)
				
	if _timer >= STATE_DURATION:
		state_machine.transition_to(&"Idle")
