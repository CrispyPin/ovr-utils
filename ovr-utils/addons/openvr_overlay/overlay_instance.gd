extends Spatial

signal width_changed
signal offset_changed
signal target_changed

const TARGETS = ["head", "left", "right", "world"]
export (String,  "head", "left", "right", "world") var target = "left" setget set_target

export var overlay_scene =\
		preload("res://addons/openvr_overlay/MissingOverlay.tscn") setget set_overlay_scene
export var width_meters = 0.4 setget set_width_in_meters
export var add_grabbing := true  # add grabbing module
export var add_cursor   := false # add cursor module

# if this is exported, all overlays sync offset when a controller is turned off/on
# this seems to be a bug with the godot editor-
var _offsets:Dictionary = {
	"head": {"pos": Vector3(0,0,-0.4), "rot": Quat()},
	"left": {"pos": Vector3(), "rot": Quat()},
	"right": {"pos": Vector3(), "rot": Quat()},
	"world": {"pos": Vector3(0,1,0), "rot": Quat()}
}

# what's actually tracking
var current_target: String = "world" setget _set_current_target# most of the time the actual target, but will fall back
var fallback = ["left", "right", "head"] # TODO setget that updates tracking (not important)
var interaction_handler: Node
var overlay_visible := true setget set_overlay_visible

var _tracker_id: int = 0

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
		if Settings.s.overlays[name].has("fallback"):
			fallback = Settings.s.overlays[name].fallback
		set_target(Settings.s.overlays[name].target)

		set_width_in_meters(Settings.s.overlays[name].width)

		for t_key in Settings.s.overlays[name].offsets:
			var t_offset = Settings.s.overlays[name].offsets[t_key]
			_offsets[t_key].pos = t_offset.pos
			_offsets[t_key].rot = t_offset.rot
		update_offset()
	else:
		#TEMP defaults (remove when dragging any overlay is possible)
		set_offset(current_target, translation, transform.basis.get_rotation_quat())
		####

		Settings.s.overlays[name] = {}
	save_settings()


func save_settings():
	Settings.s.overlays[name].target = target
	Settings.s.overlays[name].width = width_meters
	Settings.s.overlays[name].fallback = fallback

	if not Settings.s.overlays[name].has("offsets"):
		Settings.s.overlays[name]["offsets"] = {}

	for t_key in TARGETS:
		Settings.s.overlays[name].offsets[t_key] = _offsets[t_key]
	Settings.save_settings()



func update_tracker_id() -> void:
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


func update_offset() -> void:
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


func _tracker_changed(tracker_name: String, type: int, id: int):
	update_current_target()
	update_offset()


func set_target(new: String):
	target = new
	call_deferred("update_offset")
	update_current_target()
#	save_settings()


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


func set_width_in_meters(width: float):
	width_meters = width
	$OverlayViewport.overlay_width_in_meters = width_meters
	emit_signal("width_changed")


func set_overlay_scene(scene: PackedScene):
	overlay_scene = scene
	if not container:
#		print("container does not exist yet [overlay_instance.set_overlay_scene]")
		return
	if container.get_child_count() > 0:
		container.get_child(0).queue_free()
	container.add_child(overlay_scene.instance())


func reset_offset():
	_offsets[current_target].rot = Quat()
	_offsets[current_target].pos = Vector3()
	if current_target == "world":
		_offsets[current_target].pos.z = -0.5
	update_offset()
	save_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_offset()
		emit_signal("offset_changed")

