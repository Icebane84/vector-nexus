# VECTOR NEXUS: TECHNICAL SKILLS LIBRARY

## SKILL-001: Backing-Field Resilience

- **Pattern:** Use a private variable for storage and a public property for signals.
- **Logic:** `var _hp: float; var hp: float: get: return _hp; set(v): _hp = v; signal.emit()`

## SKILL-002: Zero-Allocation Node Pooling

- **Pattern:** Circular buffers for VFX and Audio.
- **Logic:** Never use `.instantiate()` inside `spawn_vfx()`; reuse nodes from a pre-allocated array.

## SKILL-003: Atomic State Transitions

- **Pattern:** Frame-locked timers in `_physics_process`.
- **Logic:** `_timer -= delta; if _timer <= 0: _advance_phase()`.
