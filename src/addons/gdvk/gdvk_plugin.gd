tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GDVK", "res://addons/gdvk/GDVK.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("GDVK")
