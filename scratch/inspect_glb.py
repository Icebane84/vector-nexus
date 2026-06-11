# inspect_glb.py
import json
import struct

glb_path = "assets/Models/Model.glb"
with open(glb_path, "rb") as f:
    # Read GLB header: magic (4 bytes), version (4 bytes), length (4 bytes)
    header = f.read(12)
    if len(header) < 12:
        print("Invalid GLB header")
        exit()

    magic, version, length = struct.unpack("<4sII", header)
    if magic != b"glTF":
        print("Not a glTF GLB file")
        exit()

    print(f"GLB Version: {version}, Length: {length} bytes")

    # Read chunk 0 (JSON): chunkLength (4 bytes), chunkType (4 bytes)
    chunk_header = f.read(8)
    if len(chunk_header) < 8:
        print("Invalid chunk header")
        exit()

    chunk_length, chunk_type = struct.unpack("<II", chunk_header)
    if chunk_type != 0x4E4F534A:  # b"JSON"
        print("Chunk 0 is not JSON")
        exit()

    print(f"JSON Chunk Length: {chunk_length} bytes")
    json_data = f.read(chunk_length)
    gltf_json = json.loads(json_data.decode("utf-8", errors="ignore"))

    # Extract animation names
    animations = gltf_json.get("animations", [])
    print(f"Total animations found: {len(animations)}")
    for i, anim in enumerate(animations):
        print(f" - Animation {i}: {anim.get('name')}")
