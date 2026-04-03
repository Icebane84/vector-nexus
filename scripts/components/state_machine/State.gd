extends Node
class_name State
enum ID { IDLE, MOVE, ATTACK, DODGE, PARRY, STAGGER, CHASE }
@export var state_id: ID
@warning_ignore("unused_signal")
signal transitioned(to: ID)
var actor: CharacterBody3D
var anim: AnimationPlayer
func init_state(p_actor: CharacterBody3D, p_anim: AnimationPlayer):
	actor = p_actor; anim = p_anim
func enter(): pass
func exit(): pass
func physics_update(_delta: float): pass
