# VECTOR NEXUS: TECHNICAL SKILLS LIBRARY (v4.4)

## SKILL-001: Backing-Field Resilience (Property Setters)

* **What:** A defensive programming pattern for variable assignment.
* **How:** Use a private variable (prefixed with `_`) to store data and a public property with a `set` function to trigger logic or signals.
* **Why:** Prevents infinite recursion crashes and ensures that secondary effects (like UI updates) only occur when data actually changes.

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

* **What:** A memory-management strategy for high-frequency objects like particles and sounds.
* **How:** Pre-instantiate a fixed array of nodes during `_ready()` and use a circular index to reuse them.
* **Why:** Eliminates "garbage collection stutters" during intense combat by preventing the engine from constantly creating and deleting objects.

---

## SKILL-003: Atomic State Transitions (Combat Logic)

* **What:** A deterministic method for managing animation and logic phases.
* **How:** Use float timers and delta-accumulation within `_physics_process` instead of `await` or `SceneTreeTimers`.
* **Why:** Ensures that combat logic is frame-locked and interruptible, allowing for mechanics like hit-stun or parries to stop an attack mid-swing.

---

## SKILL-004: Decoupled Global Signaling (The Synapse)

* **What:** A communication pattern that prevents hard dependencies between nodes.
* **How:** Route all major game events (Death, Loot, Quest progress) through a dedicated **GameEvents** Autoload.
* **Why:** Allows a "Death" event to trigger a UI screen, a sound effect, and a quest update simultaneously without any of those systems needing to "know" about each other.

---

## SKILL-005: Method-Bound Connectivity (Memory Safety)

* **What:** A strict rule for connecting signals to persistent objects.
* **How:** **STRICT PROHIBITION** of anonymous lambdas (`func():`) when connecting to Autoloads. Always use named methods (e.g., `_on_player_died`).
* **Why:** Prevents "Zombie Lambdas" that persist after a scene reload, which lead to crashes when they attempt to access deleted nodes (e.g., the `%HealthBar` error).

---
## SKILL-006: Surface-Aware Detection (Environmental Interaction)
* **What:** A resilient method for identifying ground materials and surface normals.
* **How:** Utilize a downward `RayCast3D` with `force_raycast_update()` to instantly query physics data.
* **Why:** Ensures that footsteps, landing particles, and slope-handling math are accurate without waiting for the physics frame.

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