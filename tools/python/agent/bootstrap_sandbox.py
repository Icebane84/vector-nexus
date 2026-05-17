import datetime
import os
import re
import subprocess
import sys

try:
    from e2b_code_interpreter import Sandbox
except ImportError:
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "e2b-code-interpreter"]
    )
    from e2b_code_interpreter import Sandbox

try:
    import google.generativeai as genai

    AI_AUTO_FIX_ENABLED = True
except ImportError:
    AI_AUTO_FIX_ENABLED = False

# Try importing the Obsidian API script
try:
    sys.path.append(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "scripts", "tools")
    )
    import query_obsidian_api

    OBSIDIAN_AVAILABLE = True
except ImportError:
    OBSIDIAN_AVAILABLE = False

# --- Configuration ---
# Define the root of your local Godot project.
# The script will scan this directory for .gd files to upload.
LOCAL_PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
# Define the target root in the sandbox.

REMOTE_PROJECT_ROOT = "/root/project"
# Define which subdirectories to scan for scripts.
DIRECTORIES_TO_SCAN = ["scripts", "scenes", "resources"]
# --- End Configuration ---


def attempt_ai_fix(code, errors):
    """Passes the broken code and errors to Gemini to get a corrected version."""
    if not os.environ.get("GEMINI_API_KEY"):
        raise ValueError("GEMINI_API_KEY environment variable not set.")

    genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))
    model = genai.GenerativeModel("gemini-2.5-flash")

    prompt = f"""You are an expert Godot 4.3 GDScript developer.
The following GDScript code has syntax errors. 
Please fix the errors and return ONLY the corrected complete GDScript code.
Do not include markdown formatting like ```gdscript or explanations.

ERRORS:
{errors}

CODE:
{code}
"""
    response = model.generate_content(prompt)
    fixed_code = response.text.strip()

    # Clean up markdown formatting if the model still includes it
    if fixed_code.startswith("```"):
        lines = fixed_code.split("\n")
        if lines[0].startswith("```"):
            lines = lines[1:]
        if lines[-1].startswith("```"):
            lines = lines[:-1]
        fixed_code = "\n".join(lines).strip()

    return fixed_code


def parse_tscn_to_tree(tscn_content):
    """Parses raw .tscn text into a readable indented scene tree for AI context."""
    tree_lines = []
    for line in tscn_content.split("\n"):
        line = line.strip()
        if not line.startswith("[node "):
            continue

        name_match = re.search(r'name="([^"]+)"', line)
        type_match = re.search(r'type="([^"]+)"', line)
        parent_match = re.search(r'parent="([^"]+)"', line)
        groups_match = re.search(r"groups=\[([^\]]+)\]", line)
        instance_match = re.search(r"instance=ExtResource", line)

        if not name_match:
            continue

        name = name_match.group(1)
        node_type = (
            type_match.group(1)
            if type_match
            else ("PackedScene Instance" if instance_match else "Node")
        )
        parent = parent_match.group(1) if parent_match else None
        groups = groups_match.group(1).replace('"', "") if groups_match else ""

        depth = 0
        if parent == ".":
            depth = 1
        elif parent:
            depth = parent.count("/") + 2

        indent = "  " * depth
        details = f"({node_type})"
        if groups:
            details += f" [groups: {groups}]"

        tree_lines.append(f"{indent}- {name} {details}")

    return "\n".join(tree_lines)


def setup_sandbox_with_project_files(template, local_root, remote_root, dirs_to_scan):
    """
    Scans local directories for project files, initializes a sandbox, and uploads the files.
    Returns the sandbox instance, a list of all files, and a list of scripts to check.
    """
    # 1. Scan local directories for .gd, .tscn, and .tres files
    files_to_upload = {}
    scripts_to_check = []
    print("Scanning local project for files to upload...")
    for directory in dirs_to_scan:
        scan_path = os.path.join(local_root, directory)
        if not os.path.exists(scan_path):
            continue
        for root, dirs, files in os.walk(scan_path):
            # Defensively exclude hidden directories (like .obsidian) from the walk
            dirs[:] = [d for d in dirs if not d.startswith(".")]
            for file in files:
                if file.endswith((".gd", ".tscn", ".tres")):
                    local_path = os.path.join(root, file)
                    # Create the remote path, ensuring it uses forward slashes for the sandbox's Linux environment
                    relative_path = os.path.relpath(local_path, local_root)
                    remote_path = os.path.join(remote_root, relative_path).replace(
                        "\\", "/"
                    )

                    with open(local_path, "r", encoding="utf-8") as f:
                        files_to_upload[remote_path] = f.read()
                    if file.endswith(".gd"):
                        scripts_to_check.append(remote_path)

    if not scripts_to_check:
        print("No .gd scripts found to validate. Exiting.")
        sys.exit(0)
    print(
        f"Found {len(files_to_upload)} files to upload, including {len(scripts_to_check)} scripts to validate."
    )

    # 2. Initialize E2B Sandbox with the specified template
    print(f"Initializing E2B Sandbox with template '{template}'...")
    sandbox = Sandbox(template=template)

    # Upload project.godot if it exists
    project_godot_path = os.path.join(local_root, "project.godot")
    if os.path.exists(project_godot_path):
        print("Uploading project.godot to the sandbox...")
        with open(project_godot_path, "r", encoding="utf-8") as f:
            sandbox.filesystem.write(f"{remote_root}/project.godot", f.read())

    # 3. Write all discovered scripts to the MicroVM
    print("Uploading project files to the sandbox...")
    for path, code in files_to_upload.items():
        # Ensure the directory structure exists before writing
        dir_path = path.rsplit("/", 1)[0]
        sandbox.commands.run(f"mkdir -p {dir_path}")
        sandbox.filesystem.write(path, code)

    print("File synchronization complete.")
    return sandbox, scripts_to_check, files_to_upload


def main():
    # 1. Setup Sandbox and Sync Files
    sandbox, scripts_to_check, files_to_upload = setup_sandbox_with_project_files(
        template="godot-4-3-headless-env",
        local_root=LOCAL_PROJECT_ROOT,
        remote_root=REMOTE_PROJECT_ROOT,
        dirs_to_scan=DIRECTORIES_TO_SCAN,
    )

    # 2. Auto-format code using gdtoolkit
    print("Installing gdtoolkit in the sandbox for formatting...")
    sandbox.commands.run("pip install gdtoolkit")

    print("Formatting GDScript files...")
    format_execution = sandbox.commands.run(
        "gdformat /root/project/scripts/", cwd="/root/project"
    )
    if format_execution.stdout and format_execution.stdout.strip():
        print("FORMATTER STDOUT:", format_execution.stdout.strip())

    # 3. Sync formatted files back to the local filesystem
    print("Downloading formatted files back to local disk...")
    for remote_path in scripts_to_check:
        formatted_code = sandbox.filesystem.read(remote_path)
        relative_path = remote_path.replace(REMOTE_PROJECT_ROOT + "/", "")
        local_path = os.path.join(LOCAL_PROJECT_ROOT, os.path.normpath(relative_path))
        with open(local_path, "w", encoding="utf-8") as f:
            f.write(formatted_code)
        # Update local dictionary cache to reflect formatted code
        files_to_upload[remote_path] = formatted_code

    # 4. Execute Syntactic Checks and Linting for each file
    print("Executing Godot 4.3 Headless Checks...")

    check_results = {}
    check_errors = {}
    check_warnings = {}
    has_errors = False
    ai_report_lines = ["--- AI GODOT VALIDATION REPORT ---"]

    for path in scripts_to_check:
        print(f"\n--- Checking {path} ---")
        execution = sandbox.commands.run(
            f"godot --headless --check-only {path}", cwd="/root/project"
        )

        current_errors = []
        # Route output
        if execution.stdout and execution.stdout.strip():
            print("STDOUT:", execution.stdout.strip())
        if execution.stderr and execution.stderr.strip():
            stderr_lines = execution.stderr.strip().split("\n")
            extracted_errors = []
            for i, line in enumerate(stderr_lines):
                # Capture warnings in addition to errors for stricter AI enforcement
                if "error" in line.lower() or "warning" in line.lower():
                    extracted_errors.append(line.strip())
                    # Godot typically prints the file and line number on the next line starting with "at:"
                    if i + 1 < len(stderr_lines) and "at:" in stderr_lines[i + 1]:
                        extracted_errors.append("  " + stderr_lines[i + 1].strip())

            if extracted_errors:
                print("EXTRACTED ERROR(S):")
                ai_report_lines.append(f"\n[ISSUES IN {path}]")
                current_errors = extracted_errors
                for err in extracted_errors:
                    print(f"  {err}")
                    ai_report_lines.append(f"  {err}")
            else:
                print("STDERR:", execution.stderr.strip())
                current_errors = [execution.stderr.strip()]

        # Record result instead of failing early
        if execution.exit_code != 0:
            print(f"\n[!] Syntax error detected in {path}.")
            check_results[path] = "FAIL"
            check_errors[path] = current_errors
            has_errors = True

            # --- AI AUTO FIX ---
            if AI_AUTO_FIX_ENABLED and os.environ.get("GEMINI_API_KEY"):
                print(f"[*] Attempting AI Auto-Fix for {path} using Gemini...")
                error_context = (
                    "\n".join(extracted_errors)
                    if extracted_errors
                    else execution.stderr
                )
                try:
                    fixed_code = attempt_ai_fix(files_to_upload[path], error_context)

                    # Overwrite local file
                    relative_path = path.replace(REMOTE_PROJECT_ROOT + "/", "")
                    local_path = os.path.join(
                        LOCAL_PROJECT_ROOT, os.path.normpath(relative_path)
                    )
                    with open(local_path, "w", encoding="utf-8") as f:
                        f.write(fixed_code)

                    # Update sandbox and cache for potential subsequent steps
                    sandbox.filesystem.write(path, fixed_code)
                    files_to_upload[path] = fixed_code

                    print(
                        f"[+] AI applied a fix to {local_path}. Please re-run the script to validate."
                    )
                    ai_report_lines.append(
                        f"\n[AI AUTO-FIX APPLIED TO {path}] - Re-validation required."
                    )
                except Exception as e:
                    print(f"[-] AI fix attempt failed: {e}")
        else:
            check_results[path] = "PASS"

        # Run gdlint for styling warnings
        lint_execution = sandbox.commands.run(f"gdlint {path}", cwd="/root/project")
        if lint_execution.stdout and lint_execution.stdout.strip():
            warnings = lint_execution.stdout.strip()
            print("GDLINT:\n" + warnings)
            ai_report_lines.append(f"\n[STYLE WARNINGS IN {path}]\n{warnings}")
            check_warnings[path] = warnings
        if lint_execution.stderr and lint_execution.stderr.strip():
            print("GDLINT STDERR:\n" + lint_execution.stderr.strip())

    # 5. Final Summary
    print("\n" + "=" * 50)
    print(" FINAL VALIDATION SUMMARY")
    print("=" * 50)
    for path, result in check_results.items():
        if result == "PASS":
            print(f"  [PASS] {path}")
        else:
            print(f"  [FAIL] {path}")
    print("=" * 50)

    # 6. Generate and append Scene Trees to the AI Report
    ai_report_lines.append("\n\n--- SCENE TREE STRUCTURES ---")
    for path, content in files_to_upload.items():
        if path.endswith(".tscn"):
            ai_report_lines.append(f"\n[{path}]")
            ai_report_lines.append(parse_tscn_to_tree(content))

    # Dump the AI report to a text file
    report_path = os.path.join(LOCAL_PROJECT_ROOT, "ai_validation_report.txt")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(ai_report_lines))
    print(f"\n[+] AI Context Report generated at: {report_path}")

    # 7. Append failures and warnings to Obsidian Daily Note
    if (has_errors or check_warnings) and OBSIDIAN_AVAILABLE:
        print("\nAppending validation log to Obsidian Daily Note...")
        log_content = f"\n## Godot Validation Report - {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"

        if has_errors:
            log_content += "### ❌ Syntax Errors\n"
            for path, result in check_results.items():
                if result == "FAIL":
                    log_content += f"- **{path}** failed validation.\n"
                    if path in check_errors and check_errors[path]:
                        for err in check_errors[path]:
                            log_content += f"    - `{err.strip()}`\n"

        if check_warnings:
            log_content += "### ⚠️ Style Warnings\n"
            for path, warnings in check_warnings.items():
                log_content += f"- **{path}** has style warnings.\n"
                for warning in warnings.split("\n"):
                    if warning.strip():
                        log_content += f"    - `{warning.strip()}`\n"

        # Post to Obsidian's daily note endpoint using markdown
        query_obsidian_api.query_obsidian(
            "/periodic/daily/",
            method="POST",
            data=log_content,
            content_type="text/markdown",
        )
        print("[+] Log appended to Obsidian successfully.")

    if has_errors:
        print("\n[!] Validation failed. One or more scripts contain syntax errors.")
        sys.exit(1)
    else:
        print("\n[+] All scripts passed validation successfully!")


if __name__ == "__main__":
    main()
