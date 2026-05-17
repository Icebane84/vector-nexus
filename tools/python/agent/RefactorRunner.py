import subprocess
import json
import argparse

# PHOENIX: REFACTOR RUNNER (v1.0)
# Orchestrator for the Great Refactor Loop


def run_audit():
    """Runs the governance guard and returns the violation data."""
    print("--- RUNNING GOVERNANCE AUDIT ---")
    result = subprocess.run(
        ["python", ".agent/governance_guard.py", "--json"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0 and not result.stdout:
        print(f"Error running audit: {result.stderr}")
        return None

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON audit output: {e}")
        print(f"Output was: {result.stdout}")
        return None


def apply_refactor(violation):
    """Applies a refactor using soul_forge.py based on the violation type."""
    skill_id = violation["skill_id"]
    path = violation["path"]

    if skill_id == "SKILL-001":
        var_name = violation.get("var_name")
        if not var_name:
            print(
                f"Skipping SKILL-001 at {path}:{violation['line']} - No variable name found."
            )
            return False

        print(f"Applying SKILL-001 to {var_name} in {path}")
        subprocess.run(
            ["python", ".agent/soul_forge.py", "backing-field", path, var_name],
            check=False,
        )
        return True

    if skill_id == "SKILL-005":
        line = violation["line"]
        print(f"Applying SKILL-005 to connection at {path}:{line}")
        subprocess.run(
            ["python", ".agent/soul_forge.py", "named-callback", path, str(line)],
            check=False
        )
        return True
    
    print(f"Refactor for {skill_id} not yet implemented in RefactorRunner.")
    return False


def main():
    parser = argparse.ArgumentParser(description="PHOENIX: Refactor Runner")
    parser.add_argument(
        "--batch",
        type=int,
        default=5,
        help="Maximum number of violations to fix in this run",
    )
    parser.add_argument(
        "--skill", type=str, help="Filter by specific SKILL ID (e.g., SKILL-001)"
    )
    args = parser.parse_args()

    audit_data = run_audit()
    if not audit_data:
        return

    violations = audit_data["violations"]
    if args.skill:
        violations = [v for v in violations if v["skill_id"] == args.skill]

    print(f"Found {len(violations)} total violations.")

    fixed_count = 0
    for v in violations:
        if fixed_count >= args.batch:
            break

        if apply_refactor(v):
            fixed_count += 1

    print(f"\n--- REFACTOR RUN COMPLETE: {fixed_count} applications attempted. ---")


if __name__ == "__main__":
    main()
