# res://scripts/tools/capture_simulation.py
import subprocess
import time
import os

def run_visual_simulation(duration=5, output_file="sim_output.mp4"):
    print(f"PHOENIX_LOG: Initializing Xvfb on Display :99...")
    # 1. Start Xvfb (Virtual Display)
    xvfb = subprocess.Popen(["Xvfb", ":99", "-screen", "0", "1280x720x24"])
    os.environ["DISPLAY"] = ":99"

    print(f"PHOENIX_LOG: Launching Godot Simulation...")
    # 2. Launch Godot (Assuming Main.tscn is the entry point)
    godot = subprocess.Popen([
        "godot", "--headless", "--path", ".", "res://scenes/world/Main.tscn"
    ])

    print(f"PHOENIX_LOG: Starting ffmpeg recording (Target: {output_file})...")
    # 3. Capture Display :99 for the specified duration
    ffmpeg_cmd = [
        "ffmpeg", "-y", "-f", "x11grab", "-video_size", "1280x720",
        "-i", ":99.0", "-t", str(duration), "-pix_fmt", "yuv420p", output_file
    ]
    
    # Run ffmpeg synchronously for the duration
    subprocess.run(ffmpeg_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

    print(f"PHOENIX_LOG: Cleaning up processes...")
    # 4. Cleanup
    godot.terminate()
    xvfb.terminate()
    
    if os.path.exists(output_file):
        print(f"PHOENIX_LOG: Simulation capture successful: {output_file}")
        return output_file
    else:
        print("PHOENIX_LOG: ERROR - Capture failed.")
        return None

if __name__ == "__main__":
    run_visual_simulation()