# find_all_gltf_nodes.py
import json
import struct

glb_path = "assets/Models/Model.glb"
with open(glb_path, "rb") as f:
    f.read(12)  # header
    chunk_length, chunk_type = struct.unpack("<II", f.read(8))
    json_data = f.read(chunk_length)
    gltf = json.loads(json_data.decode("utf-8"))

print("--- glTF Introspection ---")
print("Nodes in glTF:")
for i, node in enumerate(gltf.get("nodes", [])):
    print(f" - Node {i}: {node.get('name')}")

print("\nAnimations in glTF:")
for i, anim in enumerate(gltf.get("animations", [])):
    print(
        f" - Animation {i}: {anim.get('name')} with {len(anim.get('channels', []))} channels"
    )
