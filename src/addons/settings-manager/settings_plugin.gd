tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Settings", "res://addons/settings-manager/Settings.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("Settings")
