# **\[ARTIFACT START\]**

## **Genesis Stamp: 2026-03-31 | Domain: GVRN | State: \[CANONIZED\] | Tags: `OGLN_v15, GODOT_MASTER_V1, VECTOR_NEXUS`**

# **THE PHOENIX CODEX: Ultimate Godot 4.3 AI Coding Guide**

This artifact serves as the supreme operational playbook for generating `.gd` files. It guarantees that all architecture is **Type-Safe**, **Decoupled**, **Zero-Allocation**, and **Performant**. Any AI agent operating within this codebase MUST adhere strictly to these mandates.

---

## **I. The Synarche Universal Coding Standards (SUCS)**

All GDScript 2.0 code must align with these axiomatic truths:

1. **Strict Static Typing:** Every variable, parameter, and return value MUST be explicitly typed. Use `-> void` for functions without returns. **Arrays and Dictionaries MUST be statically typed** (e.g., `Array[Node2D]`, `Dictionary[StringName, Variant]`).
   - _Dissonance:_ `var speed = 600`, `func move(dir):`, `var items: Array`
   - _Truth:_ `var speed: float = 600.0`, `func move(dir: Vector2) -> void:`, `var items: Array[Node2D]`
2. **Explicit Casting:** Always cast nodes when instantiating or searching (`var enemy := scene.instantiate() as Node2D`).
3. **Zero Magic Strings & Centralized Enums:** Use `StringName` (`&"state_name"`) for zero-allocation dictionary keys and animation names. **Centralize these as constants at the top of the file** (e.g., `const ANIM_DEATH = &"death"`). **All Enums MUST be centralized in `Types.gd`** and accessed globally via the `T` class (e.g., `T.CombatState.IDLE`). Do not declare enums in individual component scripts.
4. **Relational Naming Convention (RNC):**
   - Classes/Nodes: `PascalCase` (`HitboxComponent`)
   - Variables/Functions: `snake_case` (`flux_charge`)
   - Internal Methods: `_underscore_prefix` (`_internal_component_binding()`)
   - Constants/Enums: `SCREAMING_SNAKE` (`MAX_RETRY_ATTEMPTS`)

---

## **II. The Wisdom Scars (Absolute Anti-Patterns)**

These are hard constraints. Violating them introduces catastrophic systemic dissonance.

| Scar ID    | Mandate                               | The Refinement                                                                                                                                       |
| :--------- | :------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| **III.4**  | **No `@onready` on Spawned Entities** | `@onready` causes race conditions during dynamic instantiation. Use `@export var node: Type` for Inspector assignment, or manual `setup()` bindings. |
| **III.4b** | **The "Ghost Frame" Scar**            | Always check `if not is_instance_valid(self): return` immediately after an `await` call. Entities may be destroyed while waiting.                    |
| **III.4c** | **No `load()` in Active Loops**       | Never use `load()` dynamically during gameplay. Use `preload()` for static assets, or background `ResourceLoader` for dynamic ones.                  |
| **III.5**  | **Signal Enum Wrapping**              | Enums passed into typed signal payloads MUST be cast to int: `int(T.CombatState.ATTACK)`.                                                            |
| **III.6**  | **No Autoload Self-Assignment**       | A wrapper never assigns itself. The System Node assigns itself in `_ready()`: `Director.active_system = self`.                                       |
| **III.7**  | **No `_physics_process` Stubs**       | Every function called in `_physics_process` must be fully implemented. `pass` stubs cause execution spikes.                                          |
| **III.8**  | **Spatial Casting**                   | Always cast instantiated 2D nodes to `Node2D` (not `CanvasItem`) before accessing `global_position`.                                                 |
| **III.9**  | **The Owner Paradox**                 | Never rely on `owner` for dynamically spawned nodes. Pass dependencies down via strict Dependency Injection.                                         |
| **III.11** | **No Over-Instantiation**             | Never instantiate massive batches of entities (e.g., drone fleets) in a single `_ready()` frame.                                                     |
| **IV.1**   | **Tween Enum Separation**             | `Tween.set_trans()` and `Tween.set_ease()` are distinct. Use `Tween.EASE_OUT`, not `TRANS_OUT`.                                                      |

---

## **III. Core Architectural Paradigms**

### **1\. "Signals Up, Calls Down" (The Golden Rule)**

- **Parents Call Down:** The Orchestrator (`Enemy.gd`) calls methods on its children (`hitbox.setup()`).
- **Children Signal Up:** Components emit signals (`health_depleted`). A child **never** calls `get_parent().die()`.
- **No Horizontal Communication:** Components MUST NOT call or reference each other horizontally. Siblings must route communication through the Orchestrator.

### **2\. The Two-Tier System Layer**

Global state is separated from active logic to protect the namespace.

- **The Wrapper (`scripts/globals/CORE.Kernel.Director.gd`):** A lightweight Autoload. `extends Node`. Holds `var active_system: Node`. Delegates calls: `if active_system: active_system.execute()`.
- **The System (`scripts/systems/DOMAIN.Combat.Director.gd`):** Instantiated at runtime by `Game.gd`. Registers itself: `Director.active_system = self`.

### **3\. Component-Based Orchestration (ECS-Lite)**

Break massive scripts into single-responsibility nodes linked by an Orchestrator.

- **Orchestrator (`Enemy.gd`):** Manages the physical body, animations, and Dependency Injection.
- **Definitions (`HealthComponent.gd`):** Stores data and pure math.
- **Processes (`HitboxComponent.gd` / `HurtboxComponent.gd`):** Handles physics layers, duck-typing, and event routing.
- **Actions (`StateManager.gd`):** Drives behavior by listening to Sensors (`VisionComponent`) and triggering Drivers (`NavigationComponent`).

---

## **IV. Execution Archetypes**

### **1\. The Zero-Lookup Orchestrator**

Eliminate string-lookup latency and `@onready` fragility by natively exporting dependencies.

```gdscript
extends CharacterBody2D
class_name Enemy

@export_group("Dependencies")
@export var health_node: HealthComponent
@export var hitbox_node: HitboxComponent
@export var state_machine: StateManager
@export var anim: AnimationPlayer

const ANIM_DEATH = &"death"

func setup(max_hp: float) -> void:
    assert(health_node != null, "Enemy: health_node is unassigned!")
    assert(hitbox_node != null, "Enemy: hitbox_node is unassigned!")
    assert(state_machine != null, "Enemy: state_machine is unassigned!")
    assert(anim != null, "Enemy: anim is unassigned!")

    health_node.max_health = max_hp
    health_node.current_health = max_hp

    if not health_node.health_depleted.is_connected(_on_death):
        health_node.health_depleted.connect(_on_death)

    # Dependency Injection DOWN the tree (Solves Scar III.9)
    state_machine.setup(self, anim, hitbox_node)

func _on_death() -> void:
    state_machine.process_mode = Node.PROCESS_MODE_DISABLED
    process_mode = Node.PROCESS_MODE_DISABLED

    if anim.has_animation(ANIM_DEATH):
        anim.play(ANIM_DEATH)
        await anim.animation_finished
        if not is_instance_valid(self): return

    queue_free()
```

### **2\. Zero-Allocation Object Pooling**

High-frequency entities (projectiles, VFX) must never use `queue_free()` or `SceneTreeTimer`s.

```gdscript
extends Node2D
class_name Projectile

signal returned_to_pool(proj: Projectile)

@export var hitbox: HitboxComponent

var speed: float \= 600.0
var \_lifetime_timer: float \= 0.0
var \_max_lifetime: float \= 3.0

func _physics_process(delta: float) -> void:
    # Manual timer avoids GC stutters
    _lifetime_timer += delta
    if _lifetime_timer >= _max_lifetime:
        _return_to_pool()
        return

    # Pure translation
    var direction := Vector2.RIGHT.rotated(rotation)
    global_position += direction * speed * delta

func _return_to_pool() -> void:
    # CRITICAL: Disconnect dynamic signals or use CONNECT_ONE_SHOT
    # e.g., if target.moved.is_connected(_on_target_moved): target.moved.disconnect(_on_target_moved)
    returned_to_pool.emit(self)
```

### **3\. Safe Collision Routing (Duck-Typing)**

Hitboxes and Hurtboxes interact agnostically using `is` checks.

```gdscript
extends Area2D
class_name HitboxComponent

@export var damage: float \= 10.0

func _ready() -> void:
    if not area_entered.is_connected(_on_area_entered):
        area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area is HurtboxComponent:
        var hurtbox := area as HurtboxComponent
        hurtbox.receive_damage(damage) # Call Down
```

---

## **V. The Physics & Math Substrate**

- **Vector Momentum:** For high-skill pivot movement, use multiplicative decay: `velocity *= (1.0 - (1.0 - 0.98) * delta * 60.0)`
- **Rotation:** Use `look_at(target_position)` instead of manual `atan2` math.
- **Navigation:** `NavigationAgent2D` emits `safe_velocity_calculated` \-\> The State Machine listens \-\> State applies it to `actor.velocity`. (Never call `move_and_slide()` inside a sub-component).

---

## **VI. Phoenix-Class I/O & Resilience**

All File and Resource operations must be **Never-Fail**.

1. **Return Type:** Always return the `Error` enum.
2. **Explicit Validation:** Use `FileAccess.get_open_error()`.
3. **Readable Logs:** Wrap errors in `error_string(err)` via `push_error()`.
4. **Cleanup:** Always call `file.close()`.
5. **Decoupling:** Emit an `error_occurred` signal to UI rather than tightly coupling error screens.

---

## **VII. The "Soul" of Ashen Oath (UI/UX Guidelines)**

Translate imperative visual code to Godot's declarative shader pipeline:

1. **Kinetic Feedback (Juice):**
   - Hit-stop: `Engine.time_scale = 0.05` for `0.1s`, then `Tween` back to `1.0`.
   - Screen Shake: `camera.offset = Vector2(randf(), randf()) * intensity`.
2. **Neon Bloom:** Use `WorldEnvironment` (Canvas mode, Glow Additive). Modulate raw RGB values above `1.0` (e.g., `Color(2.0, 0.2, 0.2)`) to activate HDR bloom.
3. **Flux-Syncing:** UI elements sync with `GameManager.flux_charge`.
   - Colors shift dynamically: Cyan \-\> Azure \-\> Violet \-\> Magenta.
   - `CRTShader.gdshader` (Chromatic Aberration) intensity maps directly to Flux levels (`0.4` to `2.0`).
4. **Audio-Sync:** Apply an Audio Bus Low-Pass Filter dynamically when Player HP drops below 20%.

---

## **VIII. The Pre-Flight Validation Checklist**

Before an AI agent outputs a generated `.gd` script, it **MUST** verify:

- [ ] Does `extends` declare the correct base class?
- [ ] Are **ALL** variables and return types explicitly typed (`: type`, `-> type`)?
- [ ] Are component dependencies explicitly exported (`@export var node: Type`)?
- [ ] Are there **zero** `@onready` calls inside dynamically spawned components?
- [ ] Are enums passed to signals wrapped in `int()`?
- [ ] Does the script perfectly adhere to "Signals Up, Calls Down"?
- [ ] Are dictionary keys and animations using `StringName` (`&"name"`)?
- [ ] Is file I/O properly guarded, returning the `Error` enum?
- [ ] Are all Arrays and Dictionaries statically typed?
- [ ] Is `is_instance_valid()` checked after every `await`?
- [ ] **Has `python tools/python/agent/governance_guard.py` been run and passed?**

---

## **IX. The Governance Arsenal**

To maintain "Phoenix-Pure" standards at scale, the following tools MUST be utilized during the development lifecycle:

1. **The Guard (`governance_guard.py`):**
   - **Role:** Enforcement.
   - **Usage:** Run `python tools/python/agent/governance_guard.py` to audit the `scripts/` directory for SKILL violations.
2. **The Forge (`soul_forge.py`):**
   - **Role:** Synthesis.
   - **Usage:** Automated refactoring (e.g., converting public variables to SKILL-001 backing fields).
3. **The Blackboard (`sync_blackboard.py`):**
   - **Role:** Context.
   - **Usage:** Updates the project's knowledge graph to ensure the AI Agent has 100% awareness of Sovereign Components and their connections.

---

## **\[ARTIFACT END\]**

**The Architect's Decree:** The Substrate is Truth. By internalizing this Codex, you transcend from a generative scribe to a systemic Architect. Proceed to build the Ashen Oathith absolute precision.
