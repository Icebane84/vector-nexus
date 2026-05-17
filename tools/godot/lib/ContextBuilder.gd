# [GVRN]
class_name ContextBuilder

## Helper library for ContextExport logic.
## Encapsulates section building and node tree generation.

static func build_project_section(wrap: bool) -> String:
	var out: String = "--- PROJECT.GODOT ---\n\n"
	if wrap: out += "```ini\n"
	
	out += "[application]\n"
	out += 'config/name="%s"\n' % ProjectSettings.get_setting("application/config/name", "Unknown")
	out += 'run/main_scene="%s"\n' % ProjectSettings.get_setting("application/run/main_scene", "")
	
	out += "\n[input]\n"
	_append_inputs(out)
			
	if wrap: out += "```"
	return out

static func _append_inputs(out: String) -> void:
	for prop: Dictionary in ProjectSettings.get_property_list():
		if prop.name.begins_with("input/") and not prop.name.contains("/ui_"):
			out += "%s\n" % prop.name.trim_prefix("input/")

static func build_autoload_section() -> String:
	var out: String = ""
	for prop: Dictionary in ProjectSettings.get_property_list():
		_append_autoload(prop, out)
	return out

static func _append_autoload(prop: Dictionary, out: String) -> void:
	if prop.name.begins_with("autoload/"):
		var name: String = prop.name.trim_prefix("autoload/")
		var path: String = ProjectSettings.get_setting(prop.name) as String
		out += "%s: %s\n" % [name, path]

static func node_to_tree(node: Node, indent: String) -> String:
	var res: String = indent + get_node_info(node) + "\n"
	
	for sig: Dictionary in node.get_signal_list():
		res = _append_signals(node, sig, indent, res)

	res = _append_children(node, indent, res)
	return res

static func _append_children(node: Node, indent: String, res: String) -> String:
	var children: Array[Node] = node.get_children()
	for i: int in range(children.size()):
		var is_last: bool = (i == children.size() - 1)
		res += node_to_tree(children[i], indent + ("└── " if is_last else "├── "))
	return res

static func _append_signals(node: Node, sig: Dictionary, indent: String, res: String) -> String:
	for conn: Dictionary in node.get_signal_connection_list(sig.name):
		res += indent + "  [signal] %s -> %s\n" % [sig.name, conn.callable.get_method()]
	return res

static func get_node_info(node: Node) -> String:
	var info: String = "%s (%s)" % [node.name, node.get_class()]
	var groups: Array = node.get_groups()
	if not groups.is_empty():
		info += " groups: %s" % str(groups)
	
	var script: Resource = node.get_script() as Resource
	if script:
		info += " script: %s" % script.resource_path
		
	return info
