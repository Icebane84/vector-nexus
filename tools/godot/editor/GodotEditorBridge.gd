@tool
extends Node3D

# GodotEditorBridge.gd
# Bidirectional bridge between Godot Editor and AuditResilienceService (TypeScript).
# Part of the Closed-Loop Resilience System (PHOENIX PROTOCOL v15.0).

const LISTEN_PORT = 8080
var server := TCPServer.new()
var clients: Array[StreamPeerTCP] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
		
	var err: Error = server.listen(LISTEN_PORT)
	if err == OK:
		print("[PhoenixBridge] Listening on Port %d" % LISTEN_PORT)
	else:
		printerr("[PhoenixBridge] Failed to start: %d" % err)

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
		
	if server.is_connection_available():
		var client: StreamPeerTCP = server.take_connection()
		clients.append(client)
		print("[PhoenixBridge] Client connected from %s" % client.get_connected_host())
		
	for i: int in range(clients.size() - 1, -1, -1):
		var client: StreamPeerTCP = clients[i]
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			clients.remove_at(i)
			continue
			
		if client.get_available_bytes() > 0:
			var data: Array = client.get_data(client.get_available_bytes())
			if data[0] == OK:
				var message: String = (data[1] as PackedByteArray).get_string_from_utf8()
				_handle_message(message, client)

func _handle_message(message: String, client: StreamPeerTCP) -> void:
	print("[PhoenixBridge] Received: ", message)
	
	var parts: PackedStringArray = message.split(":", true, 1)
	var action: String = parts[0].to_upper()
	var param: String = parts[1] if parts.size() > 1 else ""
	
	match action:
		"MUTATE":
			_perform_mutation(param)
		"HIGHLIGHT":
			_highlight_nodes(param)
		"PING":
			client.put_data("PONG\n".to_utf8_buffer())
		_:
			printerr("[PhoenixBridge] Unknown action: ", action)

func _perform_mutation(command: String) -> void:
	print("[PhoenixBridge] Executing Mutation: ", command)
	# Logic for authoritative scene mutation goes here.

func _highlight_nodes(paths_json: String) -> void:
	print("[PhoenixBridge] Highlighting Nodes: ", paths_json)
	# Logic for highlighting nodes in the scene tree.
