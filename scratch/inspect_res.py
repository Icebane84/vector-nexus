# inspect_res.py
import string

path = "assets/Models/ModelAnimations/mixamo_com.res"
with open(path, "rb") as f:
    data = f.read()

# Extract printable words
words = []
current_word = []
for b in data:
    char = chr(b)
    if char in string.printable and char not in string.whitespace:
        current_word.append(char)
    else:
        if len(current_word) >= 4:
            words.append("".join(current_word))
        current_word = []

unique_words = sorted(list(set(words)))
print(f"Total words: {len(unique_words)}")
for w in unique_words:
    if any(
        k in w.lower()
        for k in ["anim", "idle", "walk", "run", "jump", "fall", "mixamo", "take"]
    ):
        print(" ->", w)
