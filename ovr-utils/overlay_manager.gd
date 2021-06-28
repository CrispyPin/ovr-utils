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
	for name in Settings.s.overlays:
		if not name == "MainOverlay":
			add_overlay(name)


func add_overlay(name):
	print("Adding overlay '", name, "'")
#	var scene = load("res://overlays/" + type + ".tscn")
#	if not scene:
#		print("Unknown overlay type: '", type, "'")
#		scene = load("res://special_overlays/UnknownType.tscn")

	var instance = preload("res://addons/openvr_overlay/OverlayInstance.tscn").instance()

	instance.name = name
#	instance.overlay_scene = scene
#	instance.type = type
	instance.add_child(preload("res://OverlaySettingsSync.tscn").instance())
	add_child(instance)
	emit_signal("added_overlay", name)


func create_overlay(path, name):
	Settings.s.overlays[name] = {}
	Settings.s.overlays[name].path = path
	add_overlay(name)


func remove_overlay(name):
	print("Removing overlay '", name, "'")
	var to_remove = get_node(name)
	if not to_remove:
		print("Could not remove overlay '", name, "'")
		return
	to_remove.queue_free()
	Settings.s.overlays.erase(name)
	emit_signal("removed_overlay", name)

