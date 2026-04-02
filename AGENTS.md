# res://AGENTS.md

## VECTOR NEXUS: ARCHITECTURAL MEMORY

- **Substrate Standard:** Phoenix Codex v4.3
- **Combat Paradigm:** Zero-Allocation (Director.combat_scratchpad), Frame-Locked Delta-Timers (`physics_update`), No `await` in combat states.
- **Recursion Shielding:** All setters must use `_private` backing fields.
- **Graph Dependencies ($E$):** `StateMachine` -> `State` | `Player` -> `HealthComponent`, `Hurtbox`, `Hitbox`, `PoiseComponent`.
