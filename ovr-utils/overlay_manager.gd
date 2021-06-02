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
	if type == "":
		print("no type specified for overlay ", name)
		return
	var scene = load("res://overlays/" + type + ".tscn")
	if scene == null:
		print("Unknown overlay type: ", type, ". Skipping overlay \"", name, "\"")
		return
	var instance = preload("res://addons/openvr_overlay/OverlayInstance.tscn").instance()
	instance.name = name
	instance.overlay_scene = scene
	instance.type = type
	add_child(instance)
	emit_signal("added_overlay", name)
