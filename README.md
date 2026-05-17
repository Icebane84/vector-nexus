# Ashen Oath: The Phoenix Protocol (Cast)

Welcome to the **Ashen Oath** development environment. This project is governed by the **Phoenix Protocol v15.0 [OMEGA]**, an architectural framework designed for "Zero-Entropy" agentic development.

## 🗺️ Project Map

The codebase is strictly divided into two primary domains:

### 1. 🎮 Gameplay Logic (`/scripts`)
All game-native code resides here. It follows the **Sovereign Component Architecture**.
- **`/scripts/entities`**: Character logic (Player, Enemies, NPCs).
- **`/scripts/components`**: Modular logic blocks (Health, Stats, Hitboxes).
- **`/scripts/ui`**: User Interface elements and HUD logic.
- **`/scripts/globals`**: Autoload singletons (Director, GameEvents, Log).

### 2. 🛠️ Orchestration & Tooling (`/tools`)
The development, verification, and AI governance layer.
- **`tools/godot/`**: Engine-native tools for verification and export.
- **`tools/python/`**: AI orchestration, database sync, and simulation capture.
- **`tools/registry/`**: The "Brain" of the project. Contains the **Master Registry**, **Skill Library**, and **Phoenix Codex**.
- **`tools/data/`**: Persistent state (Blackboard DB) and temporary caches.

---

## 🤖 Guide for AI Agents

If you are an AI assistant entering this project, follow these mandates immediately:

1.  **Read the Directive**: Consult [AGENTS.md](./AGENTS.md) for your persona and operational constraints.
2.  **Verify Integrity**: Before modifying code, run `godot --headless -s tools/godot/verification/HeadlessVerification.gd` to ensure a clean baseline.
3.  **Cross-Reference Skills**: All code changes MUST adhere to the patterns in [tools/registry/SKILL_LIBRARY.md](./tools/registry/SKILL_LIBRARY.md).
4.  **Register Your Work**: Update the [tools/registry/MASTER_REGISTRY.md](./tools/registry/MASTER_REGISTRY.md) after creating new files or architectural nodes.

## 🚀 Quick Execution
- **Context Refresh**: `godot --headless -s tools/godot/export/ContextExport.gd`
- **Sanity Audit**: `godot --headless -s tools/godot/verification/ProjectSanityCheck.gd`

---
**Status**: [STABILIZED] | [SANCTIFIED]
**Governed By**: [[tools/registry/MASTER_REGISTRY.md]]
