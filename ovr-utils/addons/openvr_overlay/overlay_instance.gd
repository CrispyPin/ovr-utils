extends Node

enum TARGETS { head, left, right, world }
export (TARGETS) var target = TARGETS.head
export var overlay_scene = preload("res://addons/openvr_overlay/MissingOverlay.tscn") setget _set_overlay_scene
export var offset_pos := Vector3(0, 0, -1) setget _set_offset_pos
export var offset_rot: Vector3 setget _set_offset_rot
export var width_meters = 0.4
export var fallback_to_hmd = false # fallback is only applied if tracker is not present at startup

var _tracker_id: int = 0 setget ,get_tracker_id


func _ready() -> void:
    ARVRServer.connect("tracker_added", self, "_tracker_changed")
    ARVRServer.connect("tracker_removed", self, "_tracker_changed")

    $OverlayViewport.overlay_width_in_meters = width_meters
    $OverlayViewport.size = OverlayInit.ovr_interface.get_render_targetsize()
    if overlay_scene:
        $OverlayViewport.add_child(overlay_scene.instance())

    update_tracker_id()
    update_offset()


#func _process(_delta: float) -> void:
#    update_offset()


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
    $Offset.translation = offset_pos
    $Offset.rotation_degrees = offset_rot
    print(_tracker_id)
    match target:
        TARGETS.head:
            $OverlayViewport.track_relative_to_device(0, $Offset.transform)
        TARGETS.world:
            $OverlayViewport.overlay_position_absolute($Offset.transform)
        _:
            $OverlayViewport.track_relative_to_device(_tracker_id, $Offset.transform)


func _tracker_changed(tracker_name: String, type: int, id: int):
    print("tracker changed: ", tracker_name)
    update_tracker_id()
    update_offset()


func get_tracker_id() -> int:
    return _tracker_id


func _set_offset_pos(pos: Vector3):
    offset_pos = pos
    update_offset()


func _set_offset_rot(rot: Vector3):
    offset_rot = rot
    update_offset()


func _set_overlay_scene(scene: PackedScene):
    overlay_scene = scene
    if $OverlayViewport.get_children():
        $OverlayViewport.get_child(0).queue_free()
    $OverlayViewport.add_child(overlay_scene.instance())

