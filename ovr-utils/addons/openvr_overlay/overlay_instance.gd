extends Spatial

signal width_changed
signal offset_changed
signal target_changed

const TARGETS = ["head", "left", "right", "world"]
export (String,  "head", "left", "right", "world") var target = "left" setget set_target

export var overlay_scene =\
		preload("res://addons/openvr_overlay/MissingOverlay.tscn") setget set_overlay_scene
export var width_meters = 0.4 setget set_width_in_meters

# if this is exported, all overlays sync offset when a controller is turned off/on
# this seems to be a bug with the godot editor-
var offsets:Dictionary = {
	"head": {"pos": Vector3(0,0,-0.4), "rot": Quat()},
	"left": {"pos": Vector3(), "rot": Quat()},
	"right": {"pos": Vector3(), "rot": Quat()},
	"world": {"pos": Vector3(0,1,0), "rot": Quat()}
}

# what's actually tracking
var current_target: String = "world" setget _set_current_target# most of the time the actual target, but will fall back

var _tracker_id: int = 0

onready var container = $OverlayViewport/Container


func _ready() -> void:
	current_target = target

	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")

	$OverlayViewport.overlay_width_in_meters = width_meters
	$OverlayViewport.size = OverlayInit.ovr_interface.get_render_targetsize()
	if overlay_scene:
		container.add_child(overlay_scene.instance())

	update_tracker_id()
	update_offset()
	emit_signal("target_changed")
	set_notify_transform(true)

	call_deferred("load_settings")


func load_settings():
	if Settings.s.overlays.has(name):
		target = Settings.s.overlays[name].target
		# TODO target fallback
		update_current_target()
		set_width_in_meters(Settings.s.overlays[name].width)
		for t_key in Settings.s.overlays[name].offsets:
			var t_offset = Settings.s.overlays[name].offsets[t_key]
			offsets[t_key].pos = t_offset.pos
			offsets[t_key].rot = t_offset.rot
		update_offset()
	else:
		#TEMP defaults
		offsets[current_target].pos = translation
		offsets[current_target].rot = transform.basis.get_rotation_quat()
		update_offset()
		####

		Settings.s.overlays[name] = {}
		save_settings()


func save_settings():
	Settings.s.overlays[name].target = target
	Settings.s.overlays[name].width = width_meters

	if not Settings.s.overlays[name].has("offsets"):
		Settings.s.overlays[name]["offsets"] = {}

	for t_key in offsets:
		if not Settings.s.overlays[name].offsets.has(t_key):
			Settings.s.overlays[name].offsets[t_key] = {}
		Settings.s.overlays[name].offsets[t_key].pos = offsets[t_key].pos
		Settings.s.overlays[name].offsets[t_key].rot = offsets[t_key].rot
	Settings.save_settings()



func update_tracker_id() -> void:
	_tracker_id = -1
	if current_target in ["left", "right"]: # target is a controller
		var target_id = TARGETS.find(current_target)

		for i in ARVRServer.get_tracker_count():
			var tracker = ARVRServer.get_tracker(i)
			if tracker.get_hand() == target_id:
				_tracker_id = int(tracker.get_name().split("_")[-1])

		if _tracker_id == -1:
			# could not find controller, overlay will revert to fallback
			_tracker_id = 63 # highest tracker id (unused, at origin)


func update_offset() -> void:
	translation = offsets[current_target].pos
	transform.basis = Basis(offsets[current_target].rot)

	match current_target:
		"head":
			$OverlayViewport.track_relative_to_device(0, global_transform)
		"world":
			$OverlayViewport.overlay_position_absolute(global_transform)
		_:
			$OverlayViewport.track_relative_to_device(_tracker_id, global_transform)


func update_current_target():
	_set_current_target(target)
	# TODO fallback if not found


func _tracker_changed(tracker_name: String, type: int, id: int):
	update_tracker_id()
	update_offset()


func get_tracker_id() -> int:
	return _tracker_id


func set_target(new: String):
	target = new
	update_tracker_id()
	call_deferred("update_offset")
	update_current_target()


func _set_current_target(new: String): # overrides target
	current_target = new
	update_tracker_id()
	update_offset()
	emit_signal("target_changed")


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


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_offset()
		emit_signal("offset_changed")

