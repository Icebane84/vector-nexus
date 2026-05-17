# Ashen Oath Architecture Blueprint

## Goal

Synthesize the `context_export.txt` payload into a definitive `docs/ARCHITECTURE.md` North Star document using robust Mermaid.js diagrams and clean Markdown.

## Socratic Gate

Before execution, please clarify:

1. **Focus Metric:** Should the Mermaid diagrams prioritize runtime **Signal Flows** (event-driven logic), or structural **Entity-Component Composition** (who owns what)?
2. **Density:** Do you want a single monolithic `ARCHITECTURE.md` file, or should complex subsystems (like Player State Machines) be branched into separate documents?

## Agent Assignments

- **Phoenix Architect (v15.7)**: Lead parse logic, construct Mermaid schemas, and validate Markdown syntax.

## Tasks

- [ ] Task 1: Parse Global Dependencies from `context_export.txt`. → Verify: `[autoload]` singletons mapped.
- [ ] Task 2: Construct the "Sovereign Wrapper" Mermaid Diagram. → Verify: Director routing is visualized.
- [ ] Task 3: Construct the Component Dependency Diagram. → Verify: Hurtbox/Hitbox and Health/Poise/Stamina loops mapped.
- [ ] Task 4: Construct the State Machine Diagram. → Verify: Active states and hierarchical flow defined.
- [ ] Task 5: Synthesize and write `docs/ARCHITECTURE.md` safely. → Verify: Output generated.

## Phase X: Verification Checklist

- [ ] `docs/ARCHITECTURE.md` exists and contains beautifully formatted, clean Markdown.
- [ ] All embedded Mermaid.js graphs pass syntax checks and parse successfully.
- [ ] The document accurately reflects the ~2500 lines of parsed project context.
