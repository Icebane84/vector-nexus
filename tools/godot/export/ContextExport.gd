# [GVRN]
extends SceneTree

## Sovereign Context Exporter (Headless Bridge)
## v1.2 - Minimal orchestrator for SKILL-012 compliance

const ContextBuilder = preload("res://tools/godot/lib/ContextBuilder.gd")
const ContextCrawler = preload("res://tools/godot/lib/ContextCrawler.gd")
const OUTPUT_PATH: String = "res://context_export.txt"
const BLACK_LIST: Array[String] = [".agent", ".trunk", ".git", ".godot", "addons", "node_modules"]

var wrap_in_markdown: bool = true
var include_autoloads: bool = true

func _init() -> void:
	_run()
	quit()

func _run() -> void:
	print("SOVEREIGN_LOG: Starting Refined Context Export...")
	var content: String = ""
	
	content += ContextBuilder.build_project_section(wrap_in_markdown)
	if include_autoloads:
		content += "\n\n--- AUTOLOADS / GLOBALS ---\n\n" + ContextBuilder.build_autoload_section()

	content += "\n\n--- SCRIPTS ---\n\n" + _build_scripts_section()
	content += "\n\n--- SCENES ---\n\n" + _build_scenes_section()

	var file: FileAccess = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(content)
		print("SOVEREIGN_LOG: Export complete. Saved to: ", OUTPUT_PATH)
	else:
		printerr("SOVEREIGN_LOG: ERROR - Could not open output path for writing.")

func _build_scripts_section() -> String:
	var out: String = ""
	var scripts: Array[String] = ContextCrawler.find_files("res://scripts", ".gd", BLACK_LIST)
	for path: String in scripts:
		var f: FileAccess = FileAccess.open(path, FileAccess.READ)
		if f:
			out += "--- SCRIPT: %s ---\n" % path
			if wrap_in_markdown: out += "```gdscript\n"
			out += f.get_as_text()
			if wrap_in_markdown: out += "\n```\n\n"
	return out

func _build_scenes_section() -> String:
	var out: String = ""
	var scenes: Array[String] = ContextCrawler.find_files("res://scenes", ".tscn", BLACK_LIST)
	for path: String in scenes:
		out += "--- SCENE: %s ---\n" % path
		_process_scene(path, out)
	return out

func _process_scene(path: String, out: String) -> void:
	var ps: Resource = load(path)
	if ps is PackedScene:
		var inst: Node = (ps as PackedScene).instantiate() as Node
		if wrap_in_markdown: out += "```text\n"
		out += ContextBuilder.node_to_tree(inst, "")
		if wrap_in_markdown: out += "```\n\n"
		inst.free()
