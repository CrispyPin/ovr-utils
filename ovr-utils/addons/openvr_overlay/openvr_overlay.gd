tool
extends EditorPlugin


func _enter_tree() -> void:
    add_autoload_singleton("OverlayInit", "res://addons/openvr_overlay/overlay_init.gd")


func _exit_tree() -> void:
    remove_autoload_singleton("OverlayInit")
