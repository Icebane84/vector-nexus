# [GVRN]
# Artifact ID:   CORE.System.LogSystem
# Description:   The Master Logging Facade. Implements Rich Terminal Output (SUCS VI).
# Version:       [SOVEREIGN]
# Author:        Architect

extends Node

class_name LogSystem

@export var write_to_file: bool = true
const LOG_PATH: String = "user://logs/session.log"

var _file: FileAccess = null

func _ready() -> void:
	# SUCS III.6: Register wrapper pointer
	Log.active_system = self
	
	if write_to_file:
		_setup_log_file()
		
	Log.wow(&"LOG", "Sovereign Logging System: ACTIVE")

func _setup_log_file() -> void:
	# SUCS VI: Never-Fail File I/O
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("logs"):
		dir.make_dir("logs")
		
	_file = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if not _file:
		push_error("LogSystem: Failed to open log file at %s" % LOG_PATH)

## SUCS II.1: Strict Static Typing
func log_message(level: int, tag: StringName, msg: String) -> void:
	var timestamp := Time.get_time_string_from_system()
	var formatted_msg := "[%s][%s] %s: %s" % [timestamp, tag, _get_level_name(level), msg]
	
	# File Persistence
	if _file:
		_file.store_line(formatted_msg)
		_file.flush() # Ensure it's written even if we crash
		
	# Rich Terminal Output (SUCS: WOW Factor)
	_print_rich_terminal(level, tag, msg)

func _get_level_name(level: int) -> String:
	match level:
		T.LogLevel.INFO: return "INFO"
		T.LogLevel.WARN: return "WARN"
		T.LogLevel.ERROR: return "ERROR"
		T.LogLevel.WOW: return "WOW"
	return "???"

func _print_rich_terminal(level: int, tag: StringName, msg: String) -> void:
	var tag_color := "cyan"
	var msg_color := "white"
	
	match level:
		T.LogLevel.INFO:
			tag_color = "gray"
			print_rich("[color=%s][b][%s][/b][/color] %s" % [tag_color, tag, msg])
		T.LogLevel.WARN:
			tag_color = "yellow"
			print_rich("[color=%s][i][b][%s][/b][/i][/color] [color=yellow]%s[/color]" % [tag_color, tag, msg])
		T.LogLevel.ERROR:
			tag_color = "red"
			print_rich("[color=%s][b][%s][/b][/color] [color=orange]%s[/color]" % [tag_color, tag, msg])
		T.LogLevel.WOW:
			tag_color = "magenta"
			print_rich("[rainbow freq=1.0 sat=0.8 val=0.8][b][%s][/b][/rainbow] [color=cyan]%s[/color]" % [tag, msg])

func _exit_tree() -> void:
	if _file:
		_file.close()
