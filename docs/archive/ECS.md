# Entity-Component System (ECS)

Ashen Oath heavily relies on modular Components to build entities iteratively rather than through rigid inheritance trees (e.g., deeply nesting `BigEnemy extends Enemy extends BaseActor`).

## Component Topology Map

```mermaid
graph LR
 %% Data Models
 subgraph Data Layers
  Stats[StatsComponent<br>Vitality, ATK, Level]
  Attrib[AttributeComponent<br>Base Multipliers]
 end

 %% State Logic
 subgraph Vitality Loop
  Health[HealthComponent<br>Signal: health_changed]
  Poise[PoiseComponent<br>Signal: posture_broken]
  Stamina[StaminaComponent<br>Signal: stamina_depleted]
 end

 %% Physics Boundary
 subgraph Physics Boundary
  Hitbox(HitboxComponent Area3D)
  Hurtbox(HurtboxComponent Area3D)
 end

 %% Connections
 Hitbox -- Passes Target AttackData --> Hurtbox
 Hurtbox -- Validates Hit & I-Frames --> Health
 Hurtbox -- Validates Poise Shock --> Poise
 Data Layers -. Feeds Max Caps .-> Vitality Loop
```

## Core Modularity Rules

- **No Hierarchical Knowledge:** A `HealthComponent` does NOT care if it is attached to a Player, Boss, or Wooden Crate. It strictly accepts `.receive_damage()` and emits `health_depleted`.
- **Stat Separation:** `StatsComponent` simply holds attributes and triggers level-up arithmetic. The `HealthComponent` reads maximum calculations on initialization or when forced.
- **Physical Isolation:** Interactions exist on explicit 3D Physics Layers (Project Layers 4 and 5).
  - Layer 4: `Player_Hitbox`
  - Layer 5: `Enemy_Hitbox`
