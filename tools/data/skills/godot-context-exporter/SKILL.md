---
name: godot-context-exporter
description: Generates high-fidelity project snapshots (scene trees, signals, groups) for deep context analysis.
allowed-tools: Godot, Read, Write, Edit, PowerShell
---

# Godot Context Exporter: Sovereign Skill

> **Operational Skill** that leverages the Godot Context Exporter plugin to generate recursive, context-rich snapshots of the project's structural and logical state.

---

## When to Use This Skill

Use this skill when you need a **Deep Context Refresh** of the project. It surpasses standard `ls -R` or `grep` by:

- Visualizing **Scene Trees** in text format.
- Capturing **Signal Connections** (e.g., `timeout -> _on_timer_timeout`).
- Identifying **Groups** (e.g., `player`, `mob`).
- Analyzing **Inspector Changes** (only properties modified from defaults).

---

## Operational Procedures

### 1. Triggering the Export (Headless)

From the project root, execute the Sovereign Bridge script:

```powershell
godot --headless -s scripts/tools/ContextExport.gd
```

### 2. Output Analysis

The result is saved to `res://context_export.md`. This file is formatted in **Markdown** and contains:

- `## Project Configuration`: Key settings and Input Maps.
- `## Autoloads / Globals`: Global singletons and their states.
- `## Scripts`: Full source code of selected (critical) scripts.
- `## Scenes`: Recursive tree views of instantiated scenes.

### 3. Understanding the Scene Tree Output

| Notation                | Meaning                                                  |
| :---------------------- | :------------------------------------------------------- |
| `NodeName (Type)`       | Standard node definition.                                |
| `├──` / `└──`           | Parent-child hierarchy markers.                          |
| `(groups: ["x"])`       | Explicit group assignments.                              |
| `(changes: { "p": v })` | Properties modified in the Inspector.                    |
| `signals: [ a -> b ]`   | Logic flow connections.                                  |
| `(x50)`                 | Merged identical sibling nodes (e.g., bullets, enemies). |

---

## Anti-Patterns

| Don't                    | Do                                                                       |
| :----------------------- | :----------------------------------------------------------------------- |
| Rely on file names alone | Use the tree view to verify component nesting.                           |
| Assume signal logic      | Check the `signals:` block for exact wiring.                             |
| Ignore `(changes: ...)`  | These often hold the secret values (Speed, Health) missing from scripts. |

---

> [!TIP]
> **Sovereign Synergy**: Combine this skill with `systematic-debugging` to identify silent scene misconfigurations that `grep` cannot find.

---

## Advanced Integrations

### 4. Obsidian Knowledge Base Integration

The context export can be piped or ingested into the local Obsidian vault to maintain a living, searchable architecture document.

- Use `query_obsidian_api.py` to post the generated `context_export.md` into a designated architecture note.

### 5. Blackboard Synchronization

After running the Context Exporter, consider triggering `sync_blackboard.py` to ensure the SQLite dependencies database matches the newly verified scene structures.
