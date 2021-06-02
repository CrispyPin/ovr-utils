extends Node

signal added_overlay
signal removed_overlay

var loaded := false


func _init() -> void:
	Settings.connect("settings_loaded", self, "_load_overlays")


func _load_overlays():
	if loaded:
		return
	loaded = true
	print("Loading in overlays")
	for key in Settings.s.overlays:
		# TODO remove this check, settings should always contain "type"
		if Settings.s.overlays[key].has("type"):
			if not key == "MainOverlay":
				add_overlay(Settings.s.overlays[key].type, key)
		else:
			print("No type defined for overlay ", key)


func add_overlay(type, name):
	var scene = load("res://overlays/" + type + ".tscn")
	if not scene:
		print("Unknown overlay type: '", type, "'. Skipping overlay '", name, "'")
		return
	var instance = preload("res://addons/openvr_overlay/OverlayInstance.tscn").instance()
	instance.name = name
	instance.overlay_scene = scene
	instance.type = type
	add_child(instance)
	emit_signal("added_overlay", name)


func remove_overlay(name):
	var to_remove = get_node(name)
	if not to_remove:
		print("Could not remove overlay '", name, "'")
		return
	to_remove.queue_free()
	emit_signal("removed_overlay", name)
	Settings.s.overlays.erase(name)
	Settings.save_settings()
