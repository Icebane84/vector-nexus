# Ashen Oath Blueprint & North Star

## Goal

To synthesize the raw `context_export.txt` dump into a deterministic, living "North Star" architectural map (`docs/ARCHITECTURE.md`) that outlines all active systems, components, and intended game loops, providing a clear map for future AI-driven TDD iteration.

## Tasks

- [ ] Task 1: Deconstruct `context_export.txt` into core System Pillars (e.g., Singletons, Components, State Machines, Utilities). → Verify: All ~40+ scripts are categorized mechanically.
- [ ] Task 2: Map the "Sovereign Wrapper" Global Layer (Director, Log, GameEvents). → Verify: The flow of Singleton instantiation and reference passing is documented.
- [ ] Task 3: Map the Entity-Component System (Hitbox, Hurtbox, Poise, Stamina, LockOn Component, etc.). → Verify: Data composition and signal dependencies between components are visualized.
- [ ] Task 4: Map the State Machine & AI Logic trees (Enemy states, Player states). → Verify: Node connectivity and logical flow for combat interactions are documented.
- [ ] Task 5: Synthesize and format all findings into `docs/ARCHITECTURE.md` using Mermaid.js diagrams and clean Markdown. → Verify: `ARCHITECTURE.md` exists and accurately maps the current state of Ashen Oath

## Done When

- [ ] `docs/ARCHITECTURE.md` serves as a comprehensive, human/AI-readable North Star blueprint of the entire codebase and its structural paradigms.
- [ ] Future feature enhancements can accurately consult the Blueprint without needing to deep-parse the raw export payload.
