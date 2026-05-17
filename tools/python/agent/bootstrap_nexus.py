import os

# PHOENIX_CODEX: v4.3-GOLD-MASTER-OMEGA
project_manifest = {
    # --- GLOBALS & EVENT BUS ---
    "scripts/globals/Director.gd": """extends Node
var _p_health: HealthComponent
var player_health_component: HealthComponent:
	get: return _p_health
	set(v): _p_health = v; player_health_ready.emit(v)

var vfx_pool: Node
var audio_pool: Node
var active_combat_system: Node
var quest_system: Node
var save_manager: Node

var combat_scratchpad: Resource = Resource.new() 

signal player_health_ready(node: HealthComponent)
signal player_ready(player: Node)
signal quest_system_ready(mgr: Node)""",
    "scripts/globals/GameEvents.gd": """extends Node
signal player_died
signal enemy_killed(id: StringName)
signal item_collected(id: StringName)
signal quest_objective_completed(quest_id: StringName, obj_idx: int)""",
    # --- KINETIC SYSTEMS (The Juice) ---
    "scripts/systems/CombatDirector.gd": """extends Node
func _ready():
	Director.active_combat_system = self

func trigger_hit_stop(duration: float, time_scale: float = 0.05):
	Engine.time_scale = time_scale
	# PHOENIX_FIX: SceneTreeTimer ignores time_scale to ensure reliable unfreeze
	var timer := get_tree().create_timer(duration, true, false, true)
	timer.timeout.connect(func(): Engine.time_scale = 1.0)""",
    "scripts/systems/VFXPool.gd": """extends Node
@export var pool_size: int = 25
var _pool: Array[Node3D] = []
var _next: int = 0

func _ready():
	Director.vfx_pool = self
	for i in range(pool_size):
		var inst = Node3D.new()
		inst.set_script(load("res://scripts/systems/VFXInstance.gd"))
		add_child(inst)
		inst.hide()
		_pool.append(inst)

func spawn_vfx(pos: Vector3):
	var inst = _pool[_next]
	inst.global_position = pos
	inst.show()
	if inst.has_method(&"play"): inst.call(&"play")
	_next = (_next + 1) % _pool.size()""",
    "scripts/systems/VFXInstance.gd": """extends Node3D
func play():
	show()
	var tw = create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(hide)""",
    # --- PERSISTENCE & PROGRESSION ---
    "scripts/systems/SaveManager.gd": """extends Node
const SAVE_PATH = "user://nexus_save.res"

func _ready():
	Director.save_manager = self

func save_game(data: Dictionary):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	print("PHOENIX_LOG: State Serialized to Disk.")

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH): return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	return file.get_var()""",
    "scripts/systems/QuestManager.gd": """extends Node
var active_quests: Array = []

func _ready():
	Director.quest_system = self
	GameEvents.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(enemy_id: StringName):
	print("PHOENIX_LOG: Processing death for Quest Logic: ", enemy_id)
	# Iterate active quests and update objectives here""",
    # --- COMPONENTS (Physical Truths) ---
    "scripts/components/HealthComponent.gd": """extends Node
class_name HealthComponent
signal health_changed(curr: float, max_v: float)
signal health_depleted
@export var max_health: float = 100.0
var _current_health: float
var current_health: float:
	get: return _current_health
	set(v):
		_current_health = clamp(v, 0.0, max_health)
		health_changed.emit(_current_health, max_health)
		if _current_health <= 0.0: health_depleted.emit()
func _ready(): _current_health = max_health""",
    "scripts/components/PoiseComponent.gd": """extends Node
class_name PoiseComponent
signal posture_broken
@export var max_poise: float = 100.0
var _current_poise: float
var is_hyper_armor_active: bool = false
var current_poise: float:
	get: return _current_poise
	set(v):
		if is_hyper_armor_active: return
		_current_poise = clamp(v, 0.0, max_poise)
		if _current_poise <= 0.0: 
			posture_broken.emit()
			_current_poise = max_poise
func _ready(): _current_poise = max_poise""",
    # --- STATE MACHINE & ATOMIC PLAYER ---
    "scripts/components/state_machine/State.gd": """extends Node
class_name State
enum ID { IDLE, MOVE, ATTACK, DODGE, PARRY, STAGGER }
@export var state_id: ID
signal transitioned(to: ID)
var actor: CharacterBody3D
var anim: AnimationPlayer
func init_state(p_actor, p_anim): actor = p_actor; anim = p_anim
func enter(): pass
func exit(): pass
func physics_update(_delta): pass""",
    "scripts/components/state_machine/StateMachine.gd": """extends Node
class_name StateMachine
@export var initial_state: State
var _current_state: State
var _states: Dictionary = {}
func setup(actor, anim):
	for child in get_children():
		if child is State:
			_states[child.state_id] = child
			child.init_state(actor, anim)
			child.transitioned.connect(on_transition)
	if initial_state: _current_state = initial_state; _current_state.enter()
func _physics_process(delta): if _current_state: _current_state.physics_update(delta)
func on_transition(to):
	if not _states.has(to): return
	_current_state.exit(); _current_state = _states[to]; _current_state.enter()""",
    "scripts/entities/player/states/PlayerAttackState.gd": """extends State
class_name PlayerAttackState
enum Phase { STARTUP, ACTIVE, RECOVERY }
var _phase = Phase.STARTUP
var _timer: float = 0.0
var _buffer: bool = false
@export var startup_dur: float = 0.2
@export var active_dur: float = 0.15
@export var recovery_dur: float = 0.4
var hitbox: Area3D

func enter():
	_timer = startup_dur; _phase = Phase.STARTUP; _buffer = false
	anim.play(&"attack_startup")

func exit():
	if hitbox: hitbox.set_deferred(&"monitoring", false)

func physics_update(delta):
	_timer -= delta
	if Input.is_action_just_pressed(&"attack"): _buffer = true
	if _timer <= 0: _advance()

func _advance():
	match _phase:
		Phase.STARTUP:
			_phase = Phase.ACTIVE; _timer = active_dur
			if hitbox: hitbox.set_deferred(&"monitoring", true); anim.play(&"attack_active")
			if Director.active_combat_system: Director.active_combat_system.trigger_hit_stop(0.05)
		Phase.ACTIVE:
			_phase = Phase.RECOVERY; _timer = recovery_dur
			if hitbox: hitbox.set_deferred(&"monitoring", false); anim.play(&"attack_recovery")
		Phase.RECOVERY:
			if _buffer: enter() else: transitioned.emit(ID.IDLE)""",
    # --- AUTOMATION & MOCKS ---
    "scripts/tools/ProjectSetup.gd": """@tool
extends EditorScript
func _run():
	var layers = {1:"Environment", 2:"Player_Body", 3:"Enemy_Body", 4:"Player_Hitbox", 5:"Enemy_Hitbox", 6:"Interactables"}
	for i in layers: ProjectSettings.set_setting("layer_names/3d_physics/layer_" + str(i), layers[i])
	var actions = {"move_forward":[KEY_W], "move_back":[KEY_S], "attack":[MOUSE_BUTTON_LEFT]}
	for a in actions:
		if not ProjectSettings.has_setting("input/" + a):
			var ev = InputEventKey.new() if actions[a][0] > 10 else InputEventMouseButton.new()
			if ev is InputEventKey: ev.physical_keycode = actions[a][0]
			else: ev.button_index = actions[a][0]
			ProjectSettings.set_setting("input/" + a, {"deadzone":0.5, "events":[ev]})
	ProjectSettings.save()
	print("PHOENIX_LOG: Project Configured.")""",
    "scripts/tools/MockInputController.gd": """extends Node
var _timer: float = 0.0
var _attacked: bool = false
var _release_timer: float = 0.0
var _awaiting_release: bool = false
func _physics_process(delta):
	_timer += delta
	if _awaiting_release:
		_release_timer -= delta
		if _release_timer <= 0: _release_action(&"attack"); _awaiting_release = false
	if _timer > 1.5 and not _attacked:
		_attacked = true; _press_action(&"attack"); _awaiting_release = true; _release_timer = 0.1
func _press_action(a): var ev = InputEventAction.new(); ev.action = a; ev.pressed = true; Input.parse_input_event(ev)
func _release_action(a): var ev = InputEventAction.new(); ev.action = a; ev.pressed = false; Input.parse_input_event(ev)""",
}


def bootstrap():
    print("--- [Ashen Oath: OMEGA BOOTSTRAP] ---")
    for path, code in project_manifest.items():
        dir_path = os.path.dirname(path)
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
        with open(path, "w") as f:
            f.write(code.strip())
        print(f"Deployed: {path}")

    # Topological placeholders
    for d in [
        "resources/items",
        "resources/stats",
        "resources/quests",
        "scenes/entities",
        "scenes/world",
    ]:
        if not os.path.exists(d):
            os.makedirs(d)

    print("--- BOOTSTRAP COMPLETE. ---")


if __name__ == "__main__":
    bootstrap()
