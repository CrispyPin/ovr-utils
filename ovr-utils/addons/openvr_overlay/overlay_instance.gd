extends Spatial

signal width_changed
signal offset_changed
signal target_changed
signal overlay_visibility_changed

const TARGETS = ["head", "left", "right", "world"]
export (String,  "head", "left", "right", "world") var target = "left" setget set_target

export var overlay_scene: PackedScene = \
		preload("res://addons/openvr_overlay/MissingOverlay.tscn") setget set_overlay_scene
export var width_meters := 0.4 setget set_width_in_meters
export var add_grabbing := true  # add grabbing module
export var add_cursor   := false # add cursor module

var _tracker_id := 0
var _offsets:Dictionary = {
	"head":  {"pos": Vector3(0, 0, -0.5), "rot": Quat()},
	"left":  {"pos": Vector3(), "rot": Quat()},
	"right": {"pos": Vector3(), "rot": Quat()},
	"world": {"pos": Vector3(0,1,0), "rot": Quat()},
}

# what's actually tracking
var current_target: String = "world" setget _set_current_target
var fallback = ["left", "right", "head"] # TODO setget that updates tracking (not important)
var interaction_handler: Node
var overlay_visible := true setget set_overlay_visible
var type := "main"

onready var container = $OverlayViewport/Container


func _ready() -> void:
	current_target = target

	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")

	$OverlayViewport.size = OverlayInit.ovr_interface.get_render_targetsize()
	set_notify_transform(true)

	load_settings()
	if add_cursor or add_grabbing:
		interaction_handler = load("res://addons/openvr_overlay/OverlayInteraction.tscn").instance()
		add_child(interaction_handler)
		if add_cursor:
			add_cursor()
		if add_grabbing:
			add_grab()

	if overlay_scene:
		container.add_child(overlay_scene.instance())

	update_tracker_id()


func add_cursor():
	interaction_handler.add_child(load("res://addons/openvr_overlay/OverlayCursor.tscn").instance())


func add_grab():
	interaction_handler.add_child(load("res://addons/openvr_overlay/OverlayGrab.tscn").instance())


func load_settings():
	if Settings.s.overlays.has(name):
		var loaded = Settings.s.overlays[name]
		if loaded.has("fallback"):
			fallback = loaded.fallback
		set_target(loaded.target)

		set_width_in_meters(loaded.width)

		for t_key in loaded.offsets:
			var t_offset = loaded.offsets[t_key]
			_offsets[t_key].pos = t_offset.pos
			_offsets[t_key].rot = t_offset.rot
		update_offset()
		if loaded.has("visible"):
			set_overlay_visible(loaded.visible)
	save_settings()


func save_settings():
	if not Settings.s.overlays.has(name):
		Settings.s.overlays[name] = {}
	Settings.s.overlays[name].target = target
	Settings.s.overlays[name].width = width_meters
	Settings.s.overlays[name].fallback = fallback
	Settings.s.overlays[name].type = type

	if not Settings.s.overlays[name].has("offsets"):
		Settings.s.overlays[name]["offsets"] = {}
	for t_key in TARGETS:
		Settings.s.overlays[name].offsets[t_key] = _offsets[t_key]

	Settings.save_settings()


func update_tracker_id():
	_tracker_id = -1
	match current_target:
		"left":
			_tracker_id = OverlayInit.trackers.left
		"right":
			_tracker_id = OverlayInit.trackers.right
		_:
			return

	if _tracker_id == -1:
		# could not find controller, fallback
		print("Missing controller ", current_target, " ", target, " ", fallback, " - ", name)
		_tracker_id = 63 # highest tracker id (unused, at origin)


func update_offset():
	translation = _offsets[current_target].pos
	transform.basis = Basis(_offsets[current_target].rot)

	match current_target:
		"head":
			$OverlayViewport.track_relative_to_device(0, global_transform)
		"world":
			$OverlayViewport.overlay_position_absolute(global_transform)
		_:
			$OverlayViewport.track_relative_to_device(_tracker_id, global_transform)


func update_current_target():
	if OverlayInit.trackers[target] != -1:
		_set_current_target(target)
	else: # fallback if not found
		for f in fallback:
			if OverlayInit.trackers[f] != -1:
				_set_current_target(f)
				break
	update_tracker_id()


func set_overlay_visible(state: bool):
	overlay_visible = state
	$OverlayViewport.overlay_visible = state
	Settings.s.overlays[name].visible = state
	emit_signal("overlay_visibility_changed", state)
	save_settings()


func _tracker_changed(tracker_name: String, type: int, id: int):
	update_current_target()
	update_offset()


func set_target(new: String):
	target = new
	call_deferred("update_offset")
	update_current_target()


func _set_current_target(new: String): # overrides target
	current_target = new
	update_tracker_id()
	update_offset()
	emit_signal("target_changed")


func get_offset(offset_target: String) -> Dictionary:
	return _offsets[offset_target].duplicate()


func set_offset(offset_target: String, pos: Vector3, rot: Quat) -> void:
	_offsets[offset_target].pos = pos
	_offsets[offset_target].rot = rot
	update_offset()


func set_width_in_meters(width: float) -> void:
	width_meters = width
	$OverlayViewport.overlay_width_in_meters = width_meters
	emit_signal("width_changed")


func set_overlay_scene(scene: PackedScene) -> void:
	overlay_scene = scene
	if not container:
		return
	if container.get_child_count() > 0:
		container.get_child(0).queue_free()
	container.add_child(overlay_scene.instance())


func reset_offset() -> void:
	_offsets[current_target].rot = Quat()
	_offsets[current_target].pos = Vector3()
	if current_target == "head":
		_offsets[current_target].pos.z = -0.5
	update_offset()
	save_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_offset()
		emit_signal("offset_changed")
