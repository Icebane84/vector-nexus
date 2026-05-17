# Fix Godot Missing Dependencies and Assets

## Goal

Restore the project's ability to compile and run by resolving un-linked singletons, fixing tab/space parsing errors, and fixing missing resource paths by moving nested asset folders to `res://Assets/`.

## Tasks

- [ ] Task 1: Add `[autoload]` block to `project.godot` setting `Director`, `Log`, and `GameEvents` to `/scripts/globals/*.gd` -> Verify: Run headless Godot, no "Identifier not declared" errors appear.
- [ ] Task 2: Standardize line indentation in `PlayerMoveState.gd` (Lines 66-74) to tabs only -> Verify: File is successfully parsed by Godot compiler.
- [ ] Task 3: Setup `res://Assets/` folder structure and move `assets/.../particle-fx/Assets/Particle_FX` -> Verify: Material files load particle textures seamlessly.
- [ ] Task 4: Move `assets/.../polygon-starter/Assets/Synty` to `res://Assets/Synty` -> Verify: Scene trees find the correct mesh and material paths.
- [ ] Task 5: Re-trigger Godot headless asset re-import -> Verify: The `.godot/imported` folder successfully bridges the broken dependencies.

## Done When

- [ ] Engine launches headless parsing without any `Resource file not found` errors.
- [ ] All singletons are recognized globally across the codebase.
- [ ] `PlayerMoveState` cleanly integrates into the player state machine.
