extends Spatial

signal path_changed
signal overlay_visible_changed
signal width_changed
signal alpha_changed
signal target_changed
signal fallback_changed
signal offset_changed

const TARGETS = ["head", "left", "right", "world"]
export (String,  "head", "left", "right", "world") var target = "left" setget set_target

export var width_meters := 0.4 setget set_width_in_meters
export var alpha        := 1.0 setget set_alpha
#export var add_grabbing := true  # add grabbing module
#export var add_cursor   := false # add cursor module

var _tracker_id := 0
var _offsets:Dictionary = {
	"head":  {"pos": Vector3(0, 0, -0.35), "rot": Quat()},
	"left":  {"pos": Vector3(), "rot": Quat()},
	"right": {"pos": Vector3(), "rot": Quat()},
	"world": {"pos": Vector3(0,1,0), "rot": Quat()},
}

# what's actually tracking
var current_target: String = "world" setget _set_current_target
var fallback = ["left", "right", "head"] # TODO setget that updates tracking (not important)
var interaction_handler: Node
var overlay_visible := true setget set_overlay_visible
var path := "res://special_overlays/MainOverlay.tscn" setget set_path
var path_invalid := false
var OVERLAY_PROPERTIES: Dictionary # defined in overlay root script (optional)

onready var container = $OverlayViewport/Container
var overlay_scene: Node


func _ready() -> void:
	current_target = target

	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")

	$VROverlayViewport.size = OverlayInit.ovr_interface.get_render_targetsize()
	set_notify_transform(true)

#	if add_cursor:
#		add_cursor()
#	if add_grabbing:
#		add_grab()

	update_tracker_id()
	call_deferred("update_offset")


#func add_cursor():
#	interaction_handler.add_child(load("res://addons/openvr_overlay/OverlayCursor.tscn").instance())


#func add_grab():
#	interaction_handler.add_child(load("res://addons/openvr_overlay/OverlayGrab.tscn").instance())


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
			$VROverlayViewport.track_relative_to_device(0, global_transform)
		"world":
			$VROverlayViewport.overlay_position_absolute(global_transform)
		_:
			$VROverlayViewport.track_relative_to_device(_tracker_id, global_transform)


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
	$VROverlayViewport.overlay_visible = state
	emit_signal("overlay_visible_changed", state)


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
	$VROverlayViewport.overlay_width_in_meters = width_meters
	emit_signal("width_changed")


func set_path(new: String) -> void:
	path = new
	path_invalid = false

	var packed_overlay = load(path)
	if not packed_overlay:
		path_invalid = true
		overlay_scene = load("res://special_overlays/UnknownType.tscn").instance()
	else:
		overlay_scene = packed_overlay.instance()
	if overlay_scene.get("OVERLAY_PROPERTIES") != null:
		OVERLAY_PROPERTIES = overlay_scene.OVERLAY_PROPERTIES

	emit_signal("path_changed")

	if container.get_child_count() > 0:
		container.get_child(0).queue_free()
	container.add_child(overlay_scene)



func set_alpha(val: float):
	alpha = val
	$VROverlayViewport/TextureRect.modulate.a = val
	emit_signal("alpha_changed")


func reset_offset() -> void:
	_offsets[current_target].rot = Quat()
	_offsets[current_target].pos = Vector3()
	if current_target == "head":
		_offsets[current_target].pos.z = -0.5
	update_offset()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("offset_changed")


func get_property(name: String):
	if OVERLAY_PROPERTIES.has(name):
		return OVERLAY_PROPERTIES[name]

	return OverlayInit.OVERLAY_PROPERTIES_DEFAULT[name]
