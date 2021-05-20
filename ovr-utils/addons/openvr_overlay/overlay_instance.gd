class_name OverlayInstance
extends Spatial

signal width_changed
signal offset_changed
signal target_changed

enum TARGETS { head, left, right, world }
export (TARGETS) var target = TARGETS.head setget _set_target
export var overlay_scene = preload("res://addons/openvr_overlay/MissingOverlay.tscn")\
		setget set_overlay_scene
export var width_meters = 0.4 setget set_width_in_meters
export var fallback_to_hmd = false # fallback is only applied if tracker is not present at startup
# so this is not fully implemented

var _tracker_id: int = 0

onready var container = $OverlayViewport/PanelContainer


func _ready() -> void:
	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")

	$OverlayViewport.overlay_width_in_meters = width_meters
	$OverlayViewport.size = OverlayInit.ovr_interface.get_render_targetsize()
	if overlay_scene:
		container.add_child(overlay_scene.instance())

	update_tracker_id()
	update_offset()
	set_notify_transform(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_offset()
		emit_signal("offset_changed")


func update_tracker_id() -> void:
	_tracker_id = -1

	if target in [TARGETS.left, TARGETS.right]: # target is a controller
		for i in ARVRServer.get_tracker_count():
			var tracker = ARVRServer.get_tracker(i)
			if tracker.get_hand() == target:
				_tracker_id = int(tracker.get_name().split("_")[-1])

		if _tracker_id == -1:
			# could not find controller, overlay will revert to fallback
			# only happens if controller is missing on startup, otherwise it will register as being at origin
			if fallback_to_hmd:
				_tracker_id = 0 # HMD
			else:
				_tracker_id = 63 # World origin


func update_offset() -> void:
	match target:
		TARGETS.head:
			$OverlayViewport.track_relative_to_device(0, global_transform)
		TARGETS.world:
			$OverlayViewport.overlay_position_absolute(global_transform)
		_:
			$OverlayViewport.track_relative_to_device(_tracker_id, global_transform)


func _tracker_changed(tracker_name: String, type: int, id: int):
	update_tracker_id()
	update_offset()


func get_tracker_id() -> int:
	return _tracker_id


func _set_target(new: int):
	target = new
	update_tracker_id()
	call_deferred("update_offset")
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

