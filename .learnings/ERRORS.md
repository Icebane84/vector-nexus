# ERRORS

## [ERR-20260404-001] SpringArm3D_Feedback_Loop

**Logged**: 2026-04-04T22:50:00Z
**Priority**: high
**Status**: resolved
**Area**: config | 3d

### Summary

The SpringArm3D (Camera Probe) was physically colliding with the Player's own CharacterBody3D, causing a recursive jitter or "squiggly lines" effect.

### Error

Physically, the SpringArm3D is a Ray/Shape probe. If it exists on Layer 1 (Default) and Masks for Layer 1, it will hit any CollisionObject3D on Layer 1. Since the Player is also on Layer 1, the Camera "hits" the player, clips, and repositioning causes the player to move/vibrate.

### Context

- Implementation of Axis-Tiered Souls Camera (v22.0).
- Scene Hierarchy: Player -> CameraRoot -> SpringArm3D -> Camera3D.

### Suggested Fix

Isolate entities to descriptive layers.

- Environment: Layer 1
- Player: Layer 2
- Enemies: Layer 3
  Configure SpringArm3D to only Mask for Layer 1.

### Metadata

- Reproducible: yes
- Related Files: res://scenes/entities/Player.tscn, res://scripts/entities/player/PlayerCamera.gd
- See Also: N/A

### Resolution

- **Resolved**: 2026-04-04T22:50:00Z
- **Commit/PR**: v27.1
- **Notes**: Corrected Player.tscn layers and Masked SpringArm3D to Layer 1 only.
