tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("OverlayInit", "res://addons/openvr_overlay/overlay_init.gd")
	add_autoload_singleton("OverlayInteractionRoot", "res://addons/openvr_overlay/OverlayInteractionRoot.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("OverlayInit")
	remove_autoload_singleton("OverlayInteractionRoot")
