# res://AGENTS.md

## VECTOR NEXUS: ARCHITECTURAL MEMORY

\- \*\*Substrate Standard:\*\* Phoenix Codex v4.3

\- \*\*Combat Paradigm:\*\* Zero-Allocation (Director.combat\_scratchpad), Frame-Locked Delta-Timers (\`physics\_update\`), No \`await\` in combat states.

\- \*\*Recursion Shielding:\*\* All setters must use \`\_private\` backing fields.

\- \*\*Graph Dependencies ($E$):\*\* \`StateMachine\` \-\> \`State\` | \`Player\` \-\> \`HealthComponent\`, \`Hurtbox\`, \`Hitbox\`, \`PoiseComponent\`.

### **2\. The SHIELDA Recovery Handler (Python Orchestrator Snippet)**

This regex-based handler maps Godot 4.3 terminal errors to our FSM $R\_p$ (REPLAN) state.

import re

def shielda\_error\_handler(stderr\_output: str) \-\> dict:

    \# Pre-configured Godot 4.3 Regex

    pattern \= re.compile(r"SCRIPT ERROR: (.\*?)\\n.\*?at: (.\*?) \\(res://(.\*?):(\\d+)\\)")

    match \= pattern.search(stderr\_output)

    

    if match:

        error\_msg, func\_name, file\_path, line\_num \= match.groups()

        return {

            "fsm\_state": "$R\_p", \# Trigger REPLAN

            "root\_cause": error\_msg,

            "target\_node": f"res://{file\_path}",

            "action": f"Parse Tree-sitter AST for {file\_path} at line {line\_num} and re-propose strictly-typed fix."

        }

    return {"fsm\_state": "$Q\_c", "status": "Clean Execution"}
