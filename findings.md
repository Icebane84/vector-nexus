# Research Findings

## Current State

- The project is governed by the Phoenix Protocol (v4.5) with strict rules on naming (RNC), architecture (Sovereign Wrapper, Pure State Machines), and syntax (strict typing, zero allocation).
- Documentation exists across `docs/` (e.g., `PLAN-northstar-blueprint.md`, `ARCHITECTURE.md`, `MODULARITY.md`) and `docs/architecture/` (`ECS.md`, `GLOBALS.md`, `STATE_MACHINES.md`).
- There are multiple "PLAN" files (e.g., `PLAN-debug-cleancode.md`, `PLAN-godot-fixes.md`) which may be completed and need archiving to reduce entropy.
- The `.agent/` directory contains active governance rules (`GVRN.Master.Registry.md`, `THE PHOENIX CODEX`, `AGENTS.md`) and a database (`nexus_blackboard.db`) that is synchronized via `sync_blackboard.py`.

## Key Action Items

1. **Consolidation:** The `PLAN-northstar-blueprint.md` dictates that `docs/ARCHITECTURE.md` should be the deterministic, living "North Star". Old plans need to be cleared.
2. **Path Updates:** The codebase has been migrated to `FABRIC` and `CORE` namespaces. All docs must reflect this.
3. **Database Sync:** `sync_blackboard.py` relies on `class_name` and directory scanning. Ensuring docs use precise class names is crucial for the sync script to generate accurate dependency graphs.
