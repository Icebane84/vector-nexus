# PHOENIX: Operation Sanctification - Operational Guide

Welcome to the sanctified environment. Your development workflow is now governed by automated tools to ensure maximum technical resonance.

## 🛠️ Automated Tasks (Ctrl+Shift+B)

- **PHOENIX: Full Sanctification**: Performs a complete environment sweep. Syncs the blackboard, scans scene hierarchies, and audits the codebase for governance violations.
- **PHOENIX: Governance Audit**: Quick scan of all `.gd` files for violations of the `SKILL.md` library.

## ⚒️ Soul Forge (CLI Refactoring)

Use these commands in your terminal to rapidly align your code with the technical mandates.

### 1. Apply Backing Fields (SKILL-001)
Automatically converts a public variable into a property with a private backing field.
```powershell
python tools/python/agent/soul_forge.py backing-field <file_path> <variable_name>
```
*Example:* `python tools/python/agent/soul_forge.py backing-field scripts/entities/player/Stats.gd max_health`

### 2. Scaffold New States (SKILL-008)
Generates a new player state script following the "Phoenix-Pure" state machine pattern (delta-accumulation, no await).
```powershell
python tools/python/agent/soul_forge.py scaffold-state <StateName>
```
*Example:* `python tools/python/agent/soul_forge.py scaffold-state HeavyAttack`

## 🛡️ Governance Guard (Static Analysis)

The guard currently checks for:
- **SKILL-001**: Missing backing fields for numeric variables.
- **SKILL-003/008**: Prohibited `await` usage in physics frames.
- **SKILL-005**: Anonymous lambdas in signal connections.
- **SKILL-011**: Hardcoded input keys.
- **SOVEREIGN-001**: Use of `get_parent()` (Prohibited).

---
*PHOENIX ARCHITECT: Precise. Definitive. Sanctified.*
