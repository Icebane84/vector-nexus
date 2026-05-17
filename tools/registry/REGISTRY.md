# ASHEN OATH: SOVEREIGN TOOL REGISTRY (v1.0)

This registry catalogs all specialized tools available for the development, verification, and orchestration of the Ashen Oath project.

## 🎮 GODOT-NATIVE TOOLS (Headless Verification)

| Tool | Path | Primary Function |
| :--- | :--- | :--- |
| **Context Export** | `res://tools/godot/export/ContextExport.gd` | Generates a full system snapshot (`context_export.txt`) including scene trees, signals, and script contents. |
| **Headless Verification** | `res://tools/godot/verification/HeadlessVerification.gd` | Runs a multi-phase audit: Script loading, Scene instantiation, and Locomotion physics/input stress testing. |
| **Project Sanity Check** | `res://tools/godot/verification/ProjectSanityCheck.gd` | Verifies Autoload configuration, collision layer standards, and presence of core components on entities. |
| **Context Exporter (Plugin)** | `res://addons/godot_context_exporter/` | Editor-integrated version of the context export utility. |

---

## 🐍 EXTERNAL ORCHESTRATION TOOLS (Python)

| Tool | Path | Primary Function |
| :--- | :--- | :--- |
| **Blackboard Injector** | `tools/python/agent/SQLITE BLACKBOARD INJECTION.py` | Direct programmatic access to the `nexus_blackboard.db` SQLite database. |
| **Simulation Capture** | `tools/python/agent/capture_simulation.py` | Interfaces with Godot to record `.mp4` video of logic execution for visual verification. |
| **Bootstrap Nexus** | `tools/python/agent/bootstrap_nexus.py` | Initializes the core system directory structure and base registries. |
| **Bootstrap Sandbox** | `tools/python/agent/bootstrap_sandbox.py` | Creates a controlled environment for testing specific logic blocks without affecting the main scene. |
| **Obsidian API Query** | `tools/python/agent/query_obsidian_api.py` | Connects the agent to the Obsidian vault for deep-lore and architectural knowledge retrieval. |
| **Sync Blackboard** | `tools/python/agent/sync_blackboard.py` | Ensures data consistency between local storage and remote semantic buffers. |
| **TSCN Generator** | `tools/python/agent/.tscn generator.py` | Automated scene file generation based on high-level manifest definitions. |

---

## 📚 KNOWLEDGE & GOVERNANCE ARTIFACTS

| Artifact | Path | Purpose |
| :--- | :--- | :--- |
| **Phoenix Codex** | `tools/registry/PHOENIX_CODEX.md` | The definitive guide for AI coding standards in Godot 4. |
| **Master Registry** | `tools/registry/MASTER_REGISTRY.md` | The source of truth for file states, architectural patterns, and systemic integrity. |
| **SKILL Library** | `tools/registry/SKILL_LIBRARY.md` | Reusable technical patterns (SKILL-001 to SKILL-015) that MUST be cross-referenced for all code changes. |
| **Operational Directive** | `AGENTS.md` | Persona and operational mandates for the Phoenix Architect agent. |

---

## 🚀 EXECUTION PROTOCOLS

- **Standard Verification**: `godot --headless -s tools/godot/verification/HeadlessVerification.gd`
- **Context Refresh**: `godot --headless -s tools/godot/export/ContextExport.gd`
- **Database Query**: `python tools/python/agent/query_obsidian_api.py --query "ARCH"`
