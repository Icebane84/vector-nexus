# Ashen Oath – Error Triage Session
# Generated: 2026-05-16

## Goal
Resolve all BLOCKING parse/runtime errors before prototype can run.

## Errors (Prioritized by Severity)

### BLOCKING – Parse Errors (game cannot load)
| ID | File | Error | Status |
|----|------|-------|--------|
| E1 | COMM.Enemy.State.Idle.gd | Mixed space/tab indentation → Parse Error | [x] FIXED |
| E2 | COMP.Stats.Mana.gd | `new_value` not declared + Unreachable code | [x] FIXED |
| E3 | COMM.Enemy.EnemyBase.gd | Space indentation (lines 36-94) in tab file | [x] FIXED |
| E4 | FABRIC.System.VFXPool.gd | File not found – referenced but missing | [x] FIXED (stub created) |

### RUNTIME – Logic Errors (crash at runtime)
| ID | File | Error | Status |
|----|------|-------|--------|
| E5 | Combat.Impact.gd (Line 26) | `get()` called with 2 args; max is 1 | [x] FIXED |

### Remaining warnings (non-blocking, ignored per user)
- Shadowed global identifiers (HealthComponent, PoiseComponent, AttackData, GameEvents, State, Director)
- Unused signals in GameEvents
- Unused parameters

## Root Causes Documented

### [Wisdom Scar] Indentation mixing (E1, E3)
GDScript is whitespace-sensitive. If ANY line in a file uses spaces while others use
tabs, Godot throws a parse error. This happened because:
- Earlier AI edits used 4-space indentation
- The original file used tabs
- Godot treats them as incompatible

**Prevention**: Always write GDScript with hard tabs (`\t`). When in doubt, rewrite
the whole file rather than patching individual lines.

### [Wisdom Scar] GDScript get() signature (E5)
GDScript 4's `Object.get(property_name)` takes exactly 1 argument and returns
`null` if the property doesn't exist. There is NO 2-argument overload.
Pattern to use:
```gdscript
var raw = obj.get(&"property")
var value = raw if raw != null else default_value
```

### [Wisdom Scar] VFXPool missing (E4)
Any scene that has FABRIC.System.VFXPool.gd assigned causes a parse error if the
file doesn't exist on disk. Created a prototype-safe stub that:
- Satisfies the file reference
- Connects to GameEvents.vfx_requested
- Fails gracefully with a dev print if no VFX scene is registered

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| Mana.gd space-indented setter block | 1 | Re-indented with tabs (full rewrite) |
| EnemyBase.gd space-indented functions | 1 | Full rewrite with tabs |
| Enemy.State.Idle.gd mixed indentation | 1 | Full rewrite with tabs |
| VFXPool.gd missing | 1 | Stub created at scripts/systems/ |
| Combat.Impact.gd get() 2 args | 1 | Split into null-safe 2-step pattern |
