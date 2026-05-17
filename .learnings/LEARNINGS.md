# Ashen Oath: Sovereign Learnings Registry

## [LRN-20260405-001] best_practice

**Logged**: 2026-04-05T03:13:58Z
**Priority**: high
**Status**: resolved
**Area**: engine | physics

### Summary

Physics Feedback Loop Detection (Physics Decoupling).

### Details

The "Black Squiggly Lines" (mesh distortion/jitter) was caused by a **Physics Feedback Loop**. The `SpringArm3D` (Camera) was masking the `Player` layer (2). Because the camera is a child of the Player, its physical "hit" on the player's collision shape caused a cyclic oscillation in the parent's transform.

### Suggested Action

Always decouple the `SpringArm3D` collision mask from the `CharacterBody3D` collision layer. Standardize: Environment = Layer 1, Player = Layer 2. Mask Environment only.

### Metadata

- Source: error | user_feedback
- Related Files: res://scenes/entities/Player.tscn, res://scripts/tools/ProjectSanityCheck.gd
- Tags: godot-physics, camera-jitter, sovereign-synthesis

---

## [LRN-20260405-002] best_practice

**Logged**: 2026-04-05T03:14:15Z
**Priority**: medium
**Status**: promoted
**Area**: infra | architecture

### Summary

Two-Tier Wrapper Infrastructure (Decoupling Globals).

### Details

Globals (Autoloads) should act as pure **Wrappers** (pointers). System logic nodes should instantiate themselves or be instantiated in the tree, then register themselves to the Wrapper pointers via `_ready()`. This prevents race conditions and "Autoload Singleton" parsing errors.

### Suggested Action

Refactor all high-level directors (VFX, Combat, Audio) to self-register to the `Director.gd` wrapper. (Promoted to PHOENIX-CODEX v4.3.3).

### Metadata

- Source: best_practice
- Related Files: res://scripts/globals/Director.gd, res://scripts/systems/vfx/VFXPool.gd
- Tags: godot-architecture, sucs-iii, two-tier-systems
- Promoted: res://docs/THE PHOENIX CODEX\

### Metadata

- Source: best_practice
- Related Files: res://scripts/globals/Director.gd, res://scripts/systems/vfx/VFXPool.gd
- Tags: godot-architecture, sucs-iii, two-tier-systems
- Promoted: res://docs/THE PHOENIX CODEX\_ Ultimate Godot 4.3 AI Coding Guide.md

---

## [LRN-20260509-001] best_practice

**Logged**: 2026-05-09T03:00:00Z
**Priority**: critical
**Status**: promoted
**Area**: governance | automation

### Summary

The Governance & Refactoring Loop (Sanctification).

### Details

Establishment of the `.agent/` toolset (`governance_guard.py`, `soul_forge.py`, `sync_blackboard.py`) for automated enforcement of PHOENIX-Pure standards. This loop reduces cognitive load by automating technical debt detection (e.g., SKILL-001 backing fields) and ensuring that "Signals Up, Calls Down" is validated via a centralized SQL blackboard.

### Suggested Action

Mandate the execution of `governance_guard.py` in the **Pre-Flight Validation Checklist**. Use `soul_forge.py` for all systematic architectural migrations. (Promoted to root SKILL.md v4.5).

### Metadata

- Source: agent_reflection
- Related Files: .agent/governance_guard.py, .agent/soul_forge.py, .agent/SKILL.md
- Tags: governance, automation, phoenix-pure, soul-forge
- Promoted: res://.agent/SKILL.md

## [LRN-202605010-001] [Artificial Integrity]
