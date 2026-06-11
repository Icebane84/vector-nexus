# read_res_properties.py
import re


def inspect(path):
    print(f"\n--- Inspecting: {path} ---")
    with open(path, "rb") as f:
        data = f.read()

    # Let's extract ASCII strings of length 3-50
    strings = re.findall(b"[a-zA-Z0-9_\-\.\:\/]{3,50}", data)
    decoded = []
    for s in strings:
        try:
            decoded.append(s.decode("ascii"))
        except UnicodeDecodeError:
            continue

    unique = sorted(set(decoded))

    print(f"Total strings: {len(unique)}")
    print("Animation/State keywords found:")
    keywords = [
        "idle",
        "walk",
        "run",
        "jump",
        "fall",
        "stagger",
        "parry",
        "attack",
        "animation",
        "library",
        "take",
    ]
    count = 0
    for s in unique:
        if any(kw in s.lower() for kw in keywords):
            print(" -", s)
            count += 1
            if count > 40:
                print(" - ... (truncated)")
                break


inspect("assets/Models/ModelAnimations/mixamo_com.res")
inspect("assets/Models/ModelAnimations/Take 001.res")
