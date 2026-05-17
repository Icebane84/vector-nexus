# Refined 3rd Person Souls-Like Camera

## Goal

Transform the current basic orbit camera into a robust, "Souls-like" camera system featuring target lock-on, dynamic framing, and cinematic weight, using the reference video as inspiration.

## Socratic Gate (Clarifying Questions)

Before moving to implementation, please clarify:

1. **Target Lock-On Trigger**: Do we want a hard lock-on toggle (e.g., locking via input action `lock_on` like R3) with a reticle UI, or are we aiming for a continuous, soft-magnetic camera pull towards the nearest enemy?
2. **Target Switching**: If we use hard lock-on, do you want flick-to-switch logic (flicking mouse/right-stick left or right to switch targets)?
3. **Camera Perspective**: Should the camera be perfectly centered over the player's head, or offset over the right shoulder (framing the player in the left third of the screen)?

## Tasks

- [ ] Task 1: Create a `LockOnComponent` module that scans for `HurtboxComponent` or `EnemyBase` entities within radial/angular view. → Verify: Component returns the nearest valid target using distance and central viewport weighting.
- [ ] Task 2: Implement lock-on state override in `PlayerCamera.gd` (bypassing free-look `_target_rotation` calculation). → Verify: Camera forcefully mathematically interpolates to look at the target's center-mass.
- [ ] Task 3: Implement dynamic framing (pitch & distance adjustment). → Verify: `SpringArm3D` length and camera pitch shift dynamically to keep both player character and enemy perfectly framed vertically based on distance.
- [ ] Task 4: Hook up right-stick/mouse flicking for target cycling. → Verify: Quick, strong mouse/analog movements cycle the locked target horizontally.
- [ ] Task 5: Add UI Reticle hook. → Verify: A minimalist dot or icon binds to the target's 3D position and projects to the 2D UI screen while locked.

## Done When

- [ ] The player can toggle lock-on to any valid enemy in range.
- [ ] The camera fluidly tracks the locked enemy while preserving momentum and weight.
- [ ] Target cycling functions linearly and logically based on screen-space positions.
