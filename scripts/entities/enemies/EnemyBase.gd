extends CharacterBody3D
class_name EnemyBase
@export var state_machine: StateMachine; @export var nav_comp: NavigationComponent; var target: Node3D
func _ready():
	state_machine.setup(self, $Visuals/AnimationPlayer); nav_comp.setup(self)
	target = get_tree().get_first_node_in_group(&"player")
func _physics_process(_delta): move_and_slide()