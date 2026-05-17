# Ashen Oath — Dependency & Wiring Map
**Generated from context_export.txt — 2026-05-16**
**Source of truth for "where is X hooked up?"**

---

## 1. Autoloads (Always-Available Globals)

| Name in scene | Script | class_name | Role |
|---|---|---|---|
| `_Director` | `CORE.Kernel.Director.gd` | `Director` | Kernel orchestrator. Tracks `player`, `active_systems`. |
| `_GameEvents` | `CORE.Kernel.GameEvents.gd` | `GameEvents` | Global event bus (Synapse). All cross-system signals live here. |
| `Log` | `CORE.Log.GlobalLogger.gd` | *(none)* | Debug/log utility. |

**Access pattern:** `Director.instance`, `GameEvents.instance` — both use a static singleton via `_init()`.

> ⚠️ **Critical**: `Director.gd` in the context export references `Director.instance.active_combat_system` and `Director.instance.vfx_pool` in `Hitbox` and `Hurtbox`. These properties **do not exist** on `Director.gd` yet. They will cause a nil-access crash on first hit. See §6 for fix plan.

---

## 2. Main Scene Wiring (`scenes/world/Main.tscn`)

```
Main.tscn
 └─ [script] Main.gd (extends Node3D)
       │
       ├─ _ready()  → emits GameEvents.instance.game_state_changed(IN_GAME)
       └─ _on_game_state_changed() → sets get_tree().paused, Input.mouse_mode
```

**Entry point:** `run/main_scene = "res://scenes/world/Main.tscn"`

---

## 3. Player Wiring (`scenes/entities/Player.tscn`)

### 3a. Scene Node Tree (expected)
```
Player (CharacterBody3D)         ← COMM.Avatar.Player.gd
 ├─ Visuals (Node3D)             ← mesh + skeleton
 ├─ AnimationPlayer              ← @export var animation_player
 ├─ AnimationTree                ← @export var animation_tree
 ├─ PlayerCamera (SpringArm3D)   ← COMM.Avatar.PlayerCamera.gd, @export var camera
 │   └─ Camera3D
 ├─ StateMachine (Node)          ← FABRIC.Logic.StateMachine.gd, @export var state_machine
 │   ├─ Idle (Node)              ← COMM.Avatar.State.Idle.gd      [class: PlayerIdleState]
 │   ├─ Move (Node)              ← COMM.Avatar.State.Move.gd      [class: PlayerMoveState]
 │   ├─ Attack (Node)            ← player attack state
 │   ├─ Dodge (Node)             ← player dodge state
 │   ├─ Jump (Node)              ← player jump state
 │   ├─ Fall (Node)              ← player fall state
 │   ├─ Parry (Node)             ← player parry state
 │   └─ Stagger (Node)           ← COMM.Shared.State.Stagger.gd  [class: StaggerState]
 ├─ HealthComponent (Node)       ← COMP.Physics.Health.gd
 ├─ StaminaComponent (Node)      ← COMP.Stats.Stamina.gd
 ├─ PoiseComponent (Node)        ← COMP.Stats.Poise.gd
 ├─ SanityComponent (Node)       ← COMP.Stats.Sanity.gd
 ├─ HurtboxComponent (Area3D)    ← COMP.Physics.Hurtbox.gd
 └─ HitboxComponent (Area3D)     ← COMP.Physics.Hitbox.gd
```

### 3b. Dependency Injection Flow (`_weave_dependencies`)
`Player._ready()` calls `_weave_dependencies()` which iterates every child `State` inside `StateMachine` and injects:

| Property set on State | Source |
|---|---|
| `state.actor` | the `Player` node itself |
| `state.anim` | `Player.animation_player` |
| `state.camera` | `Player.camera` |
| `state.animation_tree` | `Player.animation_tree` (reflection: only if property exists on state) |
| `state.hurtbox` | `Player.hurtbox_component` (reflection) |
| `state.hitbox` | `Player.hitbox_component` (reflection) |

### 3c. Signal Bridge (Player → GameEvents)
Set up in `Player._setup_bridge()`:

| Local signal | Emits on GameEvents |
|---|---|
| `health_component.health_changed(cur, max)` | `GameEvents.player_health_changed` |
| `stamina_component.stamina_changed(cur, max)` | `GameEvents.player_stamina_changed` |
| `sanity_component.sanity_changed(cur, max)` | `GameEvents.player_sanity_changed` |
| `camera.target_locked(target)` | `GameEvents.lock_on_target_changed` |
| `hitbox_component.hit_registered(pos, dmg, ps)` | `GameEvents.impact_occurred` |
| `hurtbox_component.parry_successful(pos)` | `GameEvents.parry_occurred` |
| `poise_component.posture_broken` | → calls `state_machine.transition_to("Stagger")` |
| `Player._ready()` completes | `GameEvents.player_instantiated(self)` |

### 3d. Accessor Methods (used by States to get components)
```gdscript
actor.get_stamina_component()  → StaminaComponent
actor.get_health_component()   → HealthComponent
```
States should ALWAYS use these, never reach into the scene tree directly.

---

## 4. Enemy Wiring (`scenes/entities/EnemyBase.tscn`)

### 4a. Scene Node Tree (expected)
```
EnemyBase (CharacterBody3D)      ← COMM.Enemy.EnemyBase.gd
 ├─ Visuals (Node3D)
 ├─ AnimationPlayer              ← @export var anim
 ├─ StateMachine (Node)          ← FABRIC.Logic.StateMachine.gd, @export var state_machine
 │   ├─ AIIdleState (Node)       ← COMM.Enemy.State.Idle.gd   [class: AIIdleState]
 │   ├─ AIChaseState (Node)      ← COMM.Enemy.State.Chase.gd  [class: AIChaseState]
 │   └─ AIAttackState (Node)     ← COMM.Enemy.State.Attack.gd [class: AIAttackState]
 ├─ DetectionComponent (Area3D)  ← COMP.AI.Detection.gd
 ├─ NavigationAgent3D            ← used by nav_comp
 ├─ NavigationComponent (Node)   ← COMP.AI.Navigation.gd, @export var nav_comp
 ├─ HealthComponent (Node)       ← COMP.Physics.Health.gd
 ├─ PoiseComponent (Node)        ← COMP.Stats.Poise.gd
 ├─ HitboxComponent (Area3D)     ← COMP.Physics.Hitbox.gd
 └─ HurtboxComponent (Area3D)    ← COMP.Physics.Hurtbox.gd
```

### 4b. Dependency Injection Flow (`_weave_dependencies`)
`EnemyBase._ready()` iterates `state_machine` children and injects:

| Property set on State | Source |
|---|---|
| `state.actor` | the `EnemyBase` node itself |
| `state.anim` | `EnemyBase.anim` |

### 4c. Signal Bridge (Enemy → GameEvents)
Set up in `EnemyBase._setup_bridge()`:

| Local signal | Routes to |
|---|---|
| `health_component.health_depleted` | → `_on_death()` → `GameEvents.enemy_killed` |
| `hitbox_component.hit_registered(pos, dmg, ps)` | `GameEvents.impact_occurred` |
| `detection_component.target_acquired(t)` | `EnemyBase.target = t` |
| `detection_component.target_lost()` | `EnemyBase.target = null` |
| `_ready()` completes | `GameEvents.enemy_instantiated(self)` |

### 4d. Target Propagation to AI States
States read `actor.get(&"target")` (via reflection). The `target` variable lives on `EnemyBase`.
- `DetectionComponent.target_acquired` → `EnemyBase.target = t`
- `AIIdleState.physics_update` → checks `actor.get(&"target") != null` → transitions to `AIChaseState`
- `AIChaseState.physics_update` → moves toward `actor.target`

---

## 5. GameEvents Signal Map (The Full Synapse)

| Signal | Emitted by | Consumed by |
|---|---|---|
| `player_instantiated(player)` | `Player._ready()` | `Director._on_player_instantiated()` |
| `player_health_changed(cur, max)` | `Player._setup_bridge()` | HUD (not yet wired) |
| `player_stamina_changed(cur, max)` | `Player._setup_bridge()` | HUD |
| `player_sanity_changed(cur, max)` | `Player._setup_bridge()` | HUD |
| `player_mana_changed(cur, max)` | `COMP.Stats.Mana.gd` setter | HUD |
| `enemy_instantiated(enemy)` | `EnemyBase._ready()` | *(nothing yet)* |
| `enemy_killed(id)` | `EnemyBase._on_death()` | *(nothing yet — XP, quest hooks)* |
| `impact_occurred(pos, dmg, ps)` | `Player._setup_bridge()`, `EnemyBase._setup_bridge()` | VFXPool (stub), CombatSystem hit-stop |
| `parry_occurred()` | `Player._setup_bridge()` | CombatSystem parry hit-stop |
| `lock_on_target_changed(target)` | `Player._setup_bridge()` | HUD crosshair |
| `vfx_requested(id, pos, normal)` | `Player.execute_shadow_attack()` | `FABRIC.System.VFXPool` (stub) |
| `game_state_changed(state)` | `Main.gd` | `Main._on_game_state_changed()` → pause/unpause |
| `character_state_changed(actor, state)` | `StaggerState.enter()` | *(nothing yet)* |
| `core_awaken` | `Director._ready()` | *(nothing yet)* |

---

## 6. Known Wiring Gaps & Risks

| Gap | Location | Risk | Recommended Fix |
|---|---|---|---|
| `Director.instance.active_combat_system` | `COMP.Physics.Hitbox.gd:451`, `COMP.Physics.Hurtbox.gd:516` | **NIL CRASH** on first hit | Add null guard: `if Director.instance.has(&"active_combat_system") and Director.instance.active_combat_system:` |
| `Director.instance.vfx_pool` | `COMP.Physics.Hitbox.gd:454` | **NIL CRASH** on first hit | Same null guard, or route through `GameEvents.vfx_requested` instead |
| `vfx_requested` signature mismatch | `GameEvents` declares `(vfx_id, position, normal)` but `Player.execute_shadow_attack()` emits `("shadow_ghost", vfx_pos)` — only 2 args | **RUNTIME ERROR** | Add `normal` param: `GameEvents.instance.vfx_requested.emit("shadow_ghost", vfx_pos, Vector3.UP)` |
| `sanity_component` not in Player.gd @export list in context export | Declared in current `COMM.Avatar.Player.gd` but was absent in older version | May be unwired in `.tscn` | Verify in Godot Inspector: Player → sanity_component must be set |
| HUD not connected to any GameEvents stat signals | All `player_*_changed` signals emitted but nothing listens | UI meters stay empty | Wire HUD nodes to `GameEvents.instance.player_health_changed` etc. in HUD `_ready()` |
| `StateManager.gd` vs `FABRIC.Logic.StateMachine.gd` | Two state machine base classes exist | Confusion, potential double-registration | `StateManager.gd` appears to be legacy. Use only `FABRIC.Logic.StateMachine.gd`. |
| `CharacterState.gd` vs `FABRIC.Logic.State.gd` | Two state base classes | Same confusion | `CharacterState.gd` is legacy. All states should `extends State` (from `FABRIC.Logic.State.gd`). |

---

## 7. State Machine Name→Class Reference

States are registered by **Node name** (what you type in the Inspector), not by class name.
`transition_to(&"Idle")` requires the node to be named exactly `"Idle"`.

### Player States
| Node Name (in Inspector) | Script File | class_name |
|---|---|---|
| `Idle` | `COMM.Avatar.State.Idle.gd` | `PlayerIdleState` |
| `Move` | `COMM.Avatar.State.Move.gd` | `PlayerMoveState` |
| `Attack` | *(attack state script)* | — |
| `Dodge` | *(dodge state script)* | — |
| `Jump` | *(jump state script)* | — |
| `Fall` | *(fall state script)* | — |
| `Parry` | *(parry state script)* | — |
| `Stagger` | `COMM.Shared.State.Stagger.gd` | `StaggerState` |

### Enemy States
| Node Name (in Inspector) | Script File | class_name |
|---|---|---|
| `AIIdleState` | `COMM.Enemy.State.Idle.gd` | `AIIdleState` |
| `AIChaseState` | `COMM.Enemy.State.Chase.gd` | `AIChaseState` |
| `AIAttackState` | `COMM.Enemy.State.Attack.gd` | `AIAttackState` |

> ⚠️ The node name and the `transition_to()` string MUST match. If your Idle node is named `"Idle"` but code calls `transition_to(&"AIIdleState")` — it silently fails with a push_error.

---

## 8. Input Map Reference

Defined in `project.godot`:

| Action Name | Used In |
|---|---|
| `move_forward` / `move_back` / `move_left` / `move_right` | `Idle.physics_update`, `Move.physics_update`, `Kaelen._physics_process` |
| `attack` | `Idle.physics_update`, `Action.Transitions.check_standard_actions` |
| `shadow_attack` | `Action.Transitions.check_standard_actions` |
| `dodge` | `Idle.physics_update`, `Action.Transitions.check_standard_actions` |
| `parry` | `Idle.physics_update`, `Action.Transitions.check_standard_actions` |
| `jump` | `Idle.physics_update`, `Move.physics_update` |
| `lock_on` | `PlayerCamera._unhandled_input` |
| `interact` | `COMP.AI.Interaction._physics_process` |
| `ui_cancel` | `Main._unhandled_input` (pause), `PlayerCamera._unhandled_input` (mouse unlock) |

---

## 9. Quick Checklist — "Is My Player Wired?"

Run through this in the Godot Inspector on `Player.tscn`:

- [ ] `state_machine` → points to the `StateMachine` node
- [ ] `camera` → points to `PlayerCamera` node  
- [ ] `visuals` → points to `Visuals` Node3D
- [ ] `animation_tree` → points to `AnimationTree` node
- [ ] `animation_player` → points to `AnimationPlayer` node
- [ ] `health_component` → points to `HealthComponent` node
- [ ] `stamina_component` → points to `StaminaComponent` node
- [ ] `poise_component` → points to `PoiseComponent` node
- [ ] `sanity_component` → points to `SanityComponent` node
- [ ] `hurtbox_component` → points to `HurtboxComponent` Area3D node
- [ ] `hitbox_component` → points to `HitboxComponent` Area3D node
- [ ] `StateMachine.initial_state` → points to the `Idle` child node
- [ ] Player node is in group `"player"` (for enemy detection)

---

## 10. Quick Checklist — "Is My Enemy Wired?"

- [ ] `state_machine` → points to `StateMachine` node
- [ ] `anim` → points to `AnimationPlayer` node
- [ ] `detection_component` → points to `DetectionComponent` Area3D node
- [ ] `nav_comp` → points to `NavigationComponent` node
- [ ] `health_component` → points to `HealthComponent` node
- [ ] `StateMachine.initial_state` → points to `AIIdleState` child node
- [ ] Enemy node is in group `"enemy"` (for player camera lock-on)
