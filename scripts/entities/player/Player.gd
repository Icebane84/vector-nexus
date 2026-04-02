extends CharacterBody3D
class_name Player
@export var state_machine: StateMachine
@export var camera: PlayerCamera
@export var visuals: Node3D
func _ready():
	Director.player_health_component = $HealthComponent
	state_machine.setup(self, $Visuals/AnimationPlayer)
	$PoiseComponent.posture_broken.connect(func(): state_machine.on_transition(State.ID.STAGGER))
	_configure_states()
func _configure_states():
	for state in state_machine.get_children():
		if state is PlayerMoveState: state.camera = camera
		if "hurtbox" in state: state.set(&"hurtbox", $HurtboxComponent)
		if "hitbox" in state: state.set(&"hitbox", $HitboxComponent)
		if "poise_node" in state: state.set(&"poise_node", $PoiseComponent)
func _physics_process(_delta): move_and_slide()
