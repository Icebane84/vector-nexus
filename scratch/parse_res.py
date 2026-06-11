# parse_res.py
import re

res_path = "assets/Models/ModelAnimations/mixamo_com.res"
with open(res_path, "rb") as f:
    data = f.read()

# Find ASCII words of length 4 to 30
strings = re.findall(b"[a-zA-Z_][a-zA-Z0-9_]{3,30}", data)
unique_strings = sorted(
    set([s.decode("ascii", errors="ignore") for s in strings])
)

print(f"Total strings found: {len(unique_strings)}")
print("First 100 strings:")
for s in unique_strings[:100]:
    print(" -", s)
