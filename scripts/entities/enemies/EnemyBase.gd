extends CharacterBody3D
class_name EnemyBase
@export var state_machine: StateMachine; @export var nav_comp: NavigationComponent; var target: Node3D
func _ready():
	# Phoenix Resilience: Check for Nil before calling setup
	if state_machine:
		state_machine.setup(self, $Visuals/AnimationPlayer)
	else:
		push_error("PHOENIX_LOG: state_machine not assigned in EnemyBase!")
	
	if nav_comp:
		nav_comp.setup(self)
func _physics_process(_delta): move_and_slide()
