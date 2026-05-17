# Project Debug & Cleancode Plan (v16.0)

This plan implements the `/debug` and `/cleancode` directives by sanitizing the `Ashen Oath` substrate of lint errors, aligning the scene topologies with the **SKILL-007 (Director-Factory)** architecture, and resolving the `TextIO` attribute conflicts in the `Synarche` utility scripts.

## Phase 1: Substrate Sanitization (GDScript Linting)

### [MODIFY] **Whitespace Sanitization**

- **Files**:
  - [PlayerCamera.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/entities/player/PlayerCamera.gd)
  - [Director.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/globals/Director.gd)
  - [VFXPool.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/systems/vfx/VFXPool.gd)
  - [ProjectSanityCheck.gd](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/tools/ProjectSanityCheck.gd)
- **Action**: Purge all trailing whitespace to eliminate IDE noise and maintain "Zero-Entropy" standards.

## Phase 2: Topological Alignment (SKILL-007)

### [MODIFY] [Main.tscn](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scenes/world/Main.tscn)

- **Action**: Remove the `VFXPool` and `CombatDirector` nodes (Lines 32-34, 52-53).
- **Goal**: Enforce the **Director-Factory** pattern. Centralize system instantiation in the `Director` script to prevent duplicate system initialization.

## Phase 3: Utility Harmonization (Python Type-Safety)

### [MODIFY] **Synarche Workflow Scripts**

- **Files**:
  - [lint_runner.py](file:///c:/Users/Chris/Synarche_Workspace/incoming/.agent/skills/lint-and-validate/scripts/lint_runner.py)
  - [type_coverage.py](file:///c:/Users/Chris/Synarche_Workspace/incoming/.agent/skills/lint-and-validate/scripts/type_coverage.py)
- **Action**: Use `typing.cast(Any, sys.stdout).reconfigure(...)` or compatible Python 3.10+ reconfigure patterns.
- **Goal**: Eliminate the `Item "TextIO" of "TextIO | Any" has no attribute "reconfigure"` Mypy errors.

### [MODIFY] [.tscn generator.py](file:///c:/Users/Chris/Ashen Oath-3rd Person RPG/scripts/tools/.tscn%20generator.py)

- **Action**: Remove unused `import sys`.

## Phase 4: TDD Verification

### [RUN] **Audit Verification**

- Run `ProjectSanityCheck.gd` (Headless).
- Run the improved `.tscn generator.py`.
- **Expected Outcome**: Zero Errors across all audits.
