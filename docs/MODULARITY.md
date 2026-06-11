# MODULARITY & PORTABILITY GUIDE (v1.0)

@GOVERNED_BY: [MASTER_REGISTRY.md](file:///c:/Users/Chris/Ashen%20Oath-3rd%20Person%20RPG/tools/registry/MASTER_REGISTRY.md)

## 1. THE SOVEREIGN INTERFACE PRINCIPLE

Components must be "Sovereign"—capable of functioning in isolation.

### Mandatory Patterns

1. **No Global Singletons**: Never call `GameEvents`, `Director`, or `SaveManager` directly from a component.
2. **Local Signals Only**: Emit local signals (e.g., `health_changed`) rather than global ones.
3. **Injected Dependencies**: Use `@export` for required peer components. Never use `get_parent()` or hardcoded node paths.

---

## 2. THE BRIDGE PATTERN

To connect a modular component to the Global Synapse (UI/Game State), use a Bridge on the Entity.

### Example (Player Bridge)

```gdscript
# Inside [COMM.Avatar.Player.gd](file:///c:/Users/Chris/Ashen%20Oath-3rd%20Person%20RPG/scripts/entities/player/COMM.Avatar.Player.gd) _ready()
health_component.health_changed.connect(
    func(cur, max): GameEvents.instance.player_health_changed.emit(cur, max)
)
```

---

## 3. COMPONENT CHECKLIST

Before committing a new component, it must pass the **O-G-O Audit**:

- [ ] **Ownership**: Does it own its data? (e.g. `_current_stamina`)
- [ ] **Governance**: Are all dependencies `@export`? (No `get_node`)
- [ ] **Output**: Does it communicate solely via `signal`? (No direct calls to outside systems)

---

## 4. AI PROMPT SNIPPET

When generating new components, use this prompt context:

> "Implement this logic as a Sovereign Component.
>
> 1. Extend Node or Area3D.
> 2. Use @export for dependencies.
> 3. Use signals for all external communication.
> 4. Ensure zero coupling to global singletons."

---

## 5. CURRENT STANDARDS

| Component Type | Base Class | Communication               |
| :------------- | :--------- | :-------------------------- |
| **Logic**      | `Node`     | Local Signals               |
| **Physics**    | `Area3D`   | AttackData Resources        |
| **State**      | `State`    | state_machine.transition_to |

---

**Status**: ACTIVE
**Enforcement**: Sentinel Rule PF-MOD-001
