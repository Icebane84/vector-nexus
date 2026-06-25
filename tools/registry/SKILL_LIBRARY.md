# Ashen Oath: TECHNICAL SKILLS LIBRARY (v4.5)

@GOVERNED_BY: [AGENTS.md](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/AGENTS.md)

## SKILL-001: Backing-Field Resilience (Property Setters)
... (rest of the file remains same)
---

## SKILL-021: Headless-Safe Singletons (Zero-Entropy Autoloads)

- **What:** A pattern to prevent "previously freed" and "class already registered" errors in CI pipelines.
- **How:**
  1. **Decoupled Names:** In `project.godot`, give Autoloads a prefixed name (e.g., `_Director`).
  2. **Script class_name:** Keep the `class_name` (e.g., `Director`) in the script.
  3. **Static Access:** Use `Director.instance` in code.
- **Why:** Prevents the "already registered" collision by ensuring the Autoload instance variable doesn't share the same identifier as the script's `class_name`.

---

## SKILL-022: Explicit Dependency Preloading (CI Resilience)

- **What:** Hardening core entities against volatile global name resolution in headless mode.
- **How:** Use `const` preloads inside scripts for core dependencies (Director, GameEvents, State).
- **Why:** Ensures that even if the engine's global scope is unstable during initial headless parsing, the script has a direct reference to its dependencies.

```gdscript
const Director = preload("res://scripts/globals/CORE.Kernel.Director.gd")
const State = preload("res://scripts/components/state_machine/FABRIC.Logic.State.gd")
```

- **What:** A defensive programming pattern for variable assignment.
- **How:** Use a private variable (prefixed with `_`) to store data and a public property with a `set` function to trigger logic or signals.
- **Why:** Prevents infinite recursion crashes and ensures that secondary effects (like UI updates) only occur when data actually changes.

```gdscript
var _current_health: float
var current_health: float:
    get: return _current_health
    set(v):
        _current_health = clamp(v, 0.0, max_health)
        health_changed.emit(_current_health, max_health)
```

---

## SKILL-002: Zero-Allocation Pooling (Feedback Systems)

- **What:** A memory-management strategy for high-frequency objects like particles and sounds.
- **How:** Pre-instantiate a fixed array of nodes during `_ready()` and use a circular index to reuse them.
- **Why:** Eliminates "garbage collection stutters" during intense combat by preventing the engine from constantly creating and deleting objects.

@IMPLEMENTED_IN: [VFXPool.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/systems/FABRIC.System.VFXPool.gd), [AudioPool.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/systems/FABRIC.System.AudioPool.gd)

---

## SKILL-003: Atomic State Transitions (Combat Logic)

- **What:** A deterministic method for managing animation and logic phases.
- **How:** Use float timers and delta-accumulation within `_physics_process` instead of `await` or `SceneTreeTimers`.
- **Why:** Ensures that combat logic is frame-locked and interruptible, allowing for mechanics like hit-stun or parries to stop an attack mid-swing.

---

## SKILL-004: Decoupled Global Signaling (The Synapse)

- **What:** A communication pattern that prevents hard dependencies between nodes.
- **How:** Route all major game events (Death, Loot, Quest progress) through a dedicated **GameEvents** Autoload.
- **Why:** Allows a "Death" event to trigger a UI screen, a sound effect, and a quest update simultaneously without any of those systems needing to "know" about each other.

---

## SKILL-005: Method-Bound Connectivity (Memory Safety)

- **What:** A strict rule for connecting signals to persistent objects.
- **How:** **STRICT PROHIBITION** of anonymous lambdas (`func():`) when connecting to Autoloads. Always use named methods (e.g., `_on_player_died`).
- **Why:** Prevents "Zombie Lambdas" that persist after a scene reload, which lead to crashes when they attempt to access deleted nodes (e.g., the `%HealthBar` error).

---

## SKILL-006: Surface-Aware Detection (Environmental Interaction)

- **What:** A resilient method for identifying ground materials and surface normals.
- **How:** Utilize a downward `RayCast3D` with `force_raycast_update()` to instantly query physics data.
- **Why:** Ensures that footsteps, landing particles, and slope-handling math are accurate without waiting for the physics frame.

```gdscript
func get_surface_data() -> Dictionary:
    var rc := $GroundRayCast as RayCast3D
    rc.force_raycast_update()
    if rc.is_colliding():
        var collider = rc.get_collider()
        return {
            "normal": rc.get_collision_normal(),
            "point": rc.get_collision_point(),
            "collider": collider
        }
    return {}
```

## SKILL-007: Director-Based Initialization (Bootstrapping)

- **What:** A strict protocol for initializing the game world.
- **How:** The **Director** Autoload is the _only_ node allowed to instantiate and position core systems (CombatDirector, VFXPool, AudioStreamPlayer, QuestManager).
- **Why:** Prevents race conditions where a scene tries to access a system that hasn't been created yet. Ensures a deterministic boot order. Decouples systems from the global Autoload registry, allowing for clean script compilation.

@IMPLEMENTED_IN: [Director.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/globals/CORE.Kernel.Director.gd)

```gdscript
# In Director.gd (SKILL-007 Factory Pattern)
func _ready():
    # 1. Create the "Factory" nodes
    vfx_pool = Node3D.new(); vfx_pool.name = "VFXPool"; add_child(vfx_pool)
    audio_pool = AudioStreamPlayer.new(); audio_pool.name = "AudioPool"; add_child(audio_pool)

    # 2. Instantiate Systems and attach them to the Director
    var combat := load("res://scripts/systems/DOMAIN.Combat.Director.gd").instantiate()
    add_child(combat); combat.name = "CombatDirector"

    # 3. Emit signal so other scripts know it's safe to connect
    quest_system_ready.emit(combat)
```

## SKILL-008: The "Phoenix-Pure" State Machine (Reliability)

- **What:** A constraint for combat state logic that guarantees frame-lock and prevents "ghost inputs."
- **How:**
  1. **NO `await`:** Never use `await` inside a State's `physics_update`.
  2. **Delta Accumulation:** Use a `_timer -= delta` pattern.
  3. **Buffer Input:** Check `Input.is_action_just_pressed()` _during_ the state to queue up the next action.
- **Why:** Godot's `await` pauses the script. If the player spams "Attack" while waiting for an animation, the input is lost. This pattern ensures the game _always_ sees the input and reacts immediately when the timer expires.

```gdscript
# PlayerAttackState.gd
func physics_update(delta):
    _timer -= delta

    # Buffer the next input
    if Input.is_action_just_pressed("attack"):
        _buffer = true

    if _timer <= 0:
        match _phase:
            Phase.STARTUP:
                _phase = Phase.ACTIVE; _timer = active_dur
                # Hitbox goes LIVE here
            Phase.ACTIVE:
                _phase = Phase.RECOVERY; _timer = recovery_dur
                # Hitbox goes DEAD here
            Phase.RECOVERY:
                # Check buffer
                if _buffer:
                    # RE-ENTER ATTACK (Loop)
                    _phase = Phase.STARTUP; _timer = startup_dur
                    _buffer = false
                else:
                    # EXIT STATE
                    transitioned.emit(ID.IDLE)
```

## SKILL-009: The "One-Shot" Hitbox (Combat Safety)

- **What:** A pattern to ensure an Area3D hitbox is active for exactly one physics frame.
- **How:** Use `set_deferred("monitoring", true)` to enable collision detection, and immediately `set_deferred("monitoring", false)` at the end of the same function.
- **Why:** Prevents "Sticky Hitboxes." If the player spams attack, a standard `Area3D` might register hits on multiple frames. This pattern ensures the sword is only "solid" for the exact duration of the swing, preventing accidental multi-hits.

```gdscript
# Inside PlayerAttackState.gd

func _activate_hitbox():
    # 1. Enable collision detection
    $HitboxArea.set_deferred("monitoring", true)

    # 2. Schedule disable for the *next* physics frame
    # This ensures it only lasts for one tick
    $HitboxArea.set_deferred("monitoring", false)
```

## SKILL-010: The "Ghost-Proof" Input Buffer (User Experience)

- **What:** A strategy to prevent "Phantom Inputs" when transitioning between states.
- **How:** When entering a new state (e.g., Dodge), immediately check if the player is _already_ holding the button for the _next_ action (e.g., Attack). If so, trigger that action instantly.
- **Why:** In high-speed games, players often buffer inputs (hold a button down). If you enter a "Dodge" state, you must immediately check if they were holding "Attack." If you don't, the game feels sluggish and unresponsive.

````gdscript
# PlayerDodgeState.gd

func enter():
    # ... start dodge animation ...

    # PHOENIX FIX: Check for buffered input
    if Input.is_action_just_pressed("attack"):
        # The player was already mashing attack while dodging.
        # We must immediately transition to attack to avoid "lost input."
        transitioned.emit(ID.ATTACK)
        return

    if Input.is_action_just_pressed("dodge"):
        # Already dodging, do nothing (or reset timer)
        pass
'''
## SKILL-011: Action-Matrix Abstraction (Input)

- **Pattern:** Map ACTIONS, not BUTTONS.
- **Why:** Ensures the game is compatible with PC keyboards, Xbox, PS, and Nintendo controllers without script changes.
- **Application:** Use `Input.is_action_pressed("fire")` exclusively. Never hardcode `KEY_SPACE`.

## SKILL-012: The Sovereign Viewport (Camera)

- **Pattern:** `top_level = true` + `lerp` follow.
- **Why:** Prevents "Physics-Step Jitter" where the camera snaps during player collisions. Decoupling the viewport allows for smooth cinematic motion.

@IMPLEMENTED_IN: [PlayerCamera.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/entities/player/COMM.Avatar.PlayerCamera.gd)

---

## SKILL-013: Souls-Like Axis-Tiered Camera (Stability)

- **What:** A hierarchical pivot system for 3D third-person cameras.
- **How:** Split rotation across two nodes:
  1. **CameraRoot (Node3D)**: Handles Horizontal (Y-axis) orbit.
  2. **SpringArm3D (Child)**: Handles Vertical (X-axis) tilt and collision.
- **Smoothing:** Use a **Weighted Lerp Buffer** rather than direct input mapping.
- **Why:** Separating the axes prevents "Z-axis Roll" where the camera accidentally tilts sideways. The weighted buffer provides the signature "Dark Souls" weight and prevents high-frequency mouse jitter.

```gdscript
# Inside PlayerCamera.gd
func _unhandled_input(event):
    if event is InputEventMouseMotion:
        # Buffer the target, don't apply immediately
        _target_rotation.y -= event.relative.x * sensitivity
        _target_rotation.x -= event.relative.y * sensitivity

func _physics_process(delta):
    # Smoothly interpolate towards the target
    rotation.y = lerp_angle(rotation.y, _target_rotation.y, smoothing * delta)
    vertical_pivot.rotation.x = lerp_angle(vertical_pivot.rotation.x, _current_rotation.x, smoothing * delta)
```

---

## SKILL-014: HSM Recursive Injection (Auto-Wiring)

- **What:** A pattern for automatic dependency injection within Hierarchical State Machines.
- **How:** In the `_ready()` function of the actor (Player), loop through the StateMachine's children recursively and inject pointers to the actor, camera, and components.
- **Why:** Eliminates manual "boilerplate" wiring in the editor. Ensures that every state, no matter how deep in the hierarchy, has immediate access to the core character data.

```gdscript
func _weave_dependencies(parent: Node):
    for child in parent.get_children():
        if child is State:
            child.actor = self
            child.camera = camera
            child.hurtbox = hurtbox_component
            _weave_dependencies(child) # Recurse for nested states
```

---

## SKILL-015: Resilient Root Motion (Procedural Fallback)

- **What:** A hybrid locomotion logic that supports both high-fidelity root motion and procedural velocity.
- **How:** Query `animation_tree.get_root_motion_position()`. If the result is near zero, fall back to applying `direction * speed` to the actor's velocity.
- **Why:** Prevents characters from becoming "stuck" if an animation file is missing root-motion data or if a state is being prototyped with placeholder animations.

```gdscript
var root_motion = animation_tree.get_root_motion_position()
if root_motion.length_squared() > 0.0001:
    velocity = (visuals.global_transform.basis * root_motion) / delta
else:
    velocity = input_direction * speed
```

---

## SKILL-016: Flattened Camera-Relative Orientation

- **What:** Standardized 3rd-person character rotation based on camera perspective.
- **How:** Extract the camera basis, project the Forward and Right vectors onto the XZ plane (zeroing the Y component), and use `atan2` to calculate the target rotation.
- **Why:** Prevents the character from "tilting" into the ground or sky when the camera is looking up or down. Essential for consistent "Souls-like" movement feel.

```gdscript
var cam_basis = camera.global_transform.basis
var forward = -Vector3(cam_basis.z.x, 0, cam_basis.z.z).normalized()
var right = Vector3(cam_basis.x.x, 0, cam_basis.x.z).normalized()
var move_dir = (forward * input.y + right * input.x).normalized()

if move_dir.length() > 0.1:
    visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(-move_dir.x, -move_dir.z), speed * delta)
```

---

## SKILL-017: Automated Governance (Governance Guard)

- **What:** Continuous static analysis for PHOENIX-Pure compliance.
- **How:** Run `python tools/python/agent/governance_guard.py` before finalizing any logic change.
- **Why:** Ensures that technical debt (missing backing fields, zombie lambdas, prohibited `await` calls) is caught and remediated before it enters the runtime.

---

## SKILL-018: Sovereign Scaffolding (Soul Forge)

- **What:** Automated refactoring and script generation tool.
- **How:** Use `python tools/python/agent/soul_forge.py` to systematically apply backing fields or generate new Sovereign Components.
- **Why:** Maintains high-fidelity adherence to architectural standards by reducing manual "boilerplate" errors.

---

## SKILL-019: Blackboard Synergy (Dependency Sync)

- **What:** Global dependency graph and metadata indexing.
- **How:** Run `python tools/python/agent/sync_blackboard.py` after creating new nodes or signals.
- **Why:** Provides the Agent with a real-time "Visual Cortex" of the codebase, preventing "Orphaned Nodes" and ensuring "Signals Up, Calls Down" remains valid.

---

## SKILL-020: Agent-Synapse Metadata (Signal Discovery)

- **What:** Enhanced signal documentation for AI agents.
- **How:** Supplement standard `signal` declarations with `@signal` comments in class headers.
- **Why:** Allows AI agents to quickly identify public event interfaces without deep parsing of the logic layer.

```gdscript
# Enemy.gd
@signal died # Metadata for Agent discovery
signal died # Actual Godot implementation
```

---

## SKILL-023: Headless Verification & Dynamic Animation Cache Management

### 1. Dynamic Animation Cache Rebuilding (Godot 4)
- **What:** When programmatically modifying or adding animations to an `AnimationLibrary` already registered on an `AnimationPlayer`, Godot 4 does not automatically refresh the playback cache, causing `has_animation()` checks to fail or animations to skip.
- **How:** Explicitly remove and re-add the target library to force an internal cache rebuild.
```gdscript
# Force cache rebuild
anim.remove_animation_library(&"")
anim.add_animation_library(&"", default_lib)
```

### 2. Deferring Headless Node Verification
- **What:** Nodes instantiated inside headless scripts (e.g. unit tests inheriting from `SceneTree`) do not execute `_ready()` scripts synchronously during `add_child()`. Accessing properties or nodes setup in `_ready()` immediately after `add_child()` results in errors.
- **How:** Run tests using `call_deferred()` and wait for a process frame:
```gdscript
extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var enemy = scene.instantiate()
	root.add_child(enemy)
	await process_frame # Allow _ready() to complete
	# Run assertions here
```

### 3. CI-Safe Resource Formats
- **What:** In headless/CI environments, the parser can fail to load `.tres` resource files with `script_class="ClassName"` if the class name database has not been rebuilt.
- **How:** Omit `script_class` from the header of custom `.tres` files (rely purely on the `script = ExtResource(...)` path declaration).
```ini
# Bad (causes headless parsing errors)
[gd_resource type="Resource" script_class="ConsumableItem" load_steps=4 format=3]

# Good (resilient to cache misses)
[gd_resource type="Resource" load_steps=4 format=3]
```

---
