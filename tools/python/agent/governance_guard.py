import os
import re
import sys
import json
import argparse

# PHOENIX: GOVERNANCE GUARD (v1.1)
# Enforces Ashen Oath Technical Skills Library (SKILL.md)

# Configuration
SCRIPTS_DIR = "scripts"
SKILL_DOC = "tools/registry/SKILL_LIBRARY.md"

# Violations to check
CHECKS = {
    "SKILL-001": {
        "pattern": r"^(@export(?:_range|_enum|_flags)?\s+)?var\s+(?!_)\w+:\s*(float|int)\s*(?![:=])", # Class-level numeric var
        "message": "Public numeric variable detected without backing field or setter logic.",
        "severity": "WARNING",
        "flags": re.MULTILINE
    },
    "SKILL-003/008": {
        "pattern": r"func\s+(?:_physics_process|physics_update).*?\bawait\b", # await in physics
        "message": "Prohibited 'await' detected in physics-step logic. Use Delta-Accumulation.",
        "severity": "CRITICAL",
        "flags": re.DOTALL
    },
    "SKILL-005": {
        "pattern": r"\.connect\(.*?(?:func\(|=>)", # Lambda connection
        "message": "Anonymous lambda/function detected in connection. Use named methods to prevent Zombie Lambdas.",
        "severity": "CRITICAL"
    },
    "SKILL-011": {
        "pattern": r"Input\.is_key_pressed\(KEY_|KEY_\w+", # Hardcoded keys
        "message": "Hardcoded KEY constants detected. Map ACTIONS in Input Map instead.",
        "severity": "WARNING"
    },
    "SKILL-015": {
        "pattern": r"\bvar\s+\w+\b(?!\s*:)|func\s+\w+\([^)]*\)(?!\s*->)",
        "message": "Missing strict static typing (var: type, func -> type).",
        "severity": "CRITICAL"
    },

    "SKILL-016": {
        "pattern": r'\.play\("[^"]*"\)|\.emit_signal\("[^"]*"\)|Input\.is_action_[^(]*\("[^"]*"\)',
        "message": "Raw magic string detected. Use StringName (&\"string\") or Centralized Signals.",
        "severity": "WARNING"
    },
    "SKILL-017": {
        "pattern": r"\.instantiate\(\)(?!\s*as\s+\w+)",
        "message": "Missing explicit type casting on instantiation.",
        "severity": "CRITICAL"
    },
    "SKILL-018": {
        "pattern": r"^enum\s+\w+",
        "message": "Local enum detected. Move to scripts/globals/Types.gd for centralization.",
        "severity": "WARNING",
        "flags": re.MULTILINE
    },
    "SOVEREIGN-001": {
        "pattern": r"\.get_parent\(\)",
        "message": "Prohibited 'get_parent()' detected. Use Dependency Injection or Signals.",
        "severity": "CRITICAL"
    },
    "SKILL-012": {
        "message": "Cognitive Complexity exceeds 15. Refactor functions to simplify logic.",
        "severity": "WARNING",
        "threshold": 15
    }
}

def scan_file(path):
    """Scans a single file for violations and returns a list of results."""
    results = []
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return []

    for skill_id, check in CHECKS.items():
        if "pattern" not in check:
            continue
            
        # Check for ignore flags
        if f"[GVRN: IGNORE {skill_id}]" in content:
            continue
            
        flags = check.get("flags", 0)
        for match in re.finditer(check["pattern"], content, flags=flags):
            matched_text = match.group(0)
            line_num = content.count('\n', 0, match.start()) + 1
            # For SKILL-001, extract the variable name
            var_name = ""
            if skill_id == "SKILL-001":
                line_text = content.split('\n')[line_num-1]
                var_match = re.search(r"var\s+((?!_)\w+)", line_text)
                if var_match:
                    var_name = var_match.group(1)

            results.append({
                "path": path,
                "line": line_num,
                "skill_id": skill_id,
                "message": check["message"],
                "severity": check["severity"],
                "var_name": var_name
            })


    
    # Special Check: Cognitive Complexity (SKILL-012)
    complexity = calculate_complexity(content)
    if complexity > CHECKS["SKILL-012"]["threshold"]:
        results.append({
            "path": path,
            "line": 0,
            "skill_id": "SKILL-012",
            "message": f"Cognitive Complexity ({complexity}) exceeds 15.",
            "severity": "WARNING"
        })

    return results

def calculate_complexity(content):
    """Simple heuristic for cognitive complexity in GDScript."""
    complexity = 1
    for line in content.split('\n'):
        stripped = line.strip()
        if not stripped or stripped.startswith('#') or stripped.startswith('"""'):
            continue
        # Branching/Looping
        if re.search(r'\b(if|elif|for|while|match)\b', stripped):
            complexity += 1
        # Logical operators
        complexity += len(re.findall(r'(\b(and|or)\b|&&|\|\|)', stripped))
    return complexity

def audit(use_json=False, target_path=SCRIPTS_DIR):
    """Performs a project-wide audit of all scripts."""
    if not use_json:
        print(f"--- PHOENIX_LOG: INITIATING GOVERNANCE AUDIT in {target_path} ---")
    
    all_violations = []
    files_scanned = 0

    if os.path.isfile(target_path):
        all_violations.extend(scan_file(target_path))
        files_scanned = 1
    else:
        for root, _, files in os.walk(target_path):
            for file in files:
                if not file.endswith(".gd"):
                    continue
                
                files_scanned += 1
                path = os.path.join(root, file)
                all_violations.extend(scan_file(path))

    if use_json:
        print(json.dumps({
            "files_scanned": files_scanned,
            "violations_found": len(all_violations),
            "violations": all_violations
        }, indent=2))
    else:
        for v in all_violations:
            print(f"[{v['severity']}] {v['path']}:{v['line']} -> {v['skill_id']}: {v['message']}")
        print(f"\n--- AUDIT COMPLETE: {files_scanned} Files Scanned. {len(all_violations)} Violations Found. ---")


    
    return 1 if len(all_violations) > 0 else 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PHOENIX: Governance Guard")
    parser.add_argument("path", nargs="?", default=SCRIPTS_DIR, help="Path to scan (file or directory)")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    args = parser.parse_args()
    sys.exit(audit(args.json, args.path))
