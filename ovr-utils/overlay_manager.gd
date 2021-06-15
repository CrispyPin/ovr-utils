extends Node

signal added_overlay
signal removed_overlay
signal grab_mode_changed

var loaded := false


func _init() -> void:
	Settings.connect("settings_loaded", self, "_load_overlays")


func _ready() -> void:
	randomize()


func _load_overlays():
	if loaded:
		return
	loaded = true
	print("Loading in overlays")
	for key in Settings.s.overlays:
		if not key == "MainOverlay":
			add_overlay(Settings.s.overlays[key].type, key)


func add_overlay(type, name):
	print("Adding overlay '", name, "' of type '", type, "'")
	var scene = load("res://overlays/" + type + ".tscn")

	if not scene:
		print("Unknown overlay type: '", type, "'")
		scene = load("res://special_overlays/UnknownType.tscn")

	var instance = preload("res://addons/openvr_overlay/OverlayInstance.tscn").instance()

	instance.name = name
	instance.overlay_scene = scene
	instance.type = type
	add_child(instance)
#	instance.update_offset()
	emit_signal("added_overlay", name)


func remove_overlay(name):
	var to_remove = get_node(name)
	if not to_remove:
		print("Could not remove overlay '", name, "'")
		return
	to_remove.queue_free()
	emit_signal("removed_overlay", name)
	Settings.s.overlays.erase(name)
