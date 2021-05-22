extends Node

signal touch_on #  a controller entered
signal touch_off # a controller exited
signal trigger_on  # trigger pushed while touching
signal trigger_off # trigger released

var _touch_state = false setget ,get_touch_state
var _trigger_state = false setget ,get_trigger_state

# controller that currently the  trigger down
var _active_controller: ARVRController setget ,get_active_controller
# reference to the area node thats used for touch
var _overlay_area = preload("res://addons/openvr_overlay/interaction/OverlayArea.tscn").instance()
var _cursor_node = preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance()
var _right_is_activator = false
var _left_is_activator = false

var is_moving := false
var _pre_move_target = ""# what offset is being changed
var _mover_hand_name = ""# left or right, which hand is grabbing (/active controller)
var _mover_hand_offsets = {"pos": Vector3(), "rot": Vector3()} # original offsets for grabbing hand

onready var viewport: Viewport = get_node("../OverlayViewport")
onready var tracker_nodes = {
	"head": $VR/head,
	"left": $VR/left,
	"right": $VR/right,
	"world": $VR
}


func _ready() -> void:
	add_child(_overlay_area)
	get_node("../OverlayViewport").add_child(_cursor_node)
	_overlay_area.connect("body_entered", self, "_on_OverlayArea_entered")
	_overlay_area.connect("body_exited", self, "_on_OverlayArea_exited")

	get_parent().connect("width_changed", self, "_update_width")
	get_parent().connect("offset_changed", self, "_update_offset")
	get_parent().connect("target_changed", self, "_update_target")

	_update_width()
	_update_offset()
	_update_target()


func _process(_delta: float) -> void:
	_update_cursor()


func begin_move():
	if not _active_controller:
		print("Could not begin moving overlay, no controller active. ", get_parent().name)
		return
	is_moving = true
	_pre_move_target = get_parent().current_target
	_mover_hand_name = _active_controller.name
	_mover_hand_offsets.pos = get_parent().translation
	_mover_hand_offsets.rot = get_parent().rotation

	# offset from active controller to overlay
	var global_rot = _overlay_area.global_transform.basis.get_rotation_quat()
#	var global_rot = _overlay_area.get_parent().transform.basis.get_rotation_quat() * _overlay_area.transform.basis.get_rotation_quat()
	var hand_rot = _active_controller.transform.basis.get_rotation_quat()
	get_parent().offsets[_mover_hand_name].rot = global_rot * (hand_rot.inverse())

	get_parent().offsets[_mover_hand_name].pos = _active_controller.transform.xform_inv(_overlay_area.global_transform.origin)

	get_parent().current_target = _mover_hand_name
#	get_parent().update_tracker_id()
#	get_parent().update_offset()


func finish_move():
	is_moving = false
	var new_pos = tracker_nodes[_pre_move_target].transform.xform_inv(_overlay_area.global_transform.origin)

	var new_rot = _overlay_area.get_parent().rotation + _overlay_area.rotation - tracker_nodes[_pre_move_target].rotation
	get_parent().update_current_target()
	get_parent().update_tracker_id()
	get_parent().offsets[get_parent().current_target].pos = new_pos
#	get_parent().offsets[get_parent().current_target].rot = new_rot
	get_parent().update_offset()
	_update_target()


#get canvas position of active controller
func get_canvas_pos() -> Vector2:
	if _active_controller == null:
		return Vector2(-1000, 1000) # offscreen

	var controller_local_pos = _overlay_area.global_transform.xform_inv(\
			_active_controller.global_transform.origin)
	var pos = Vector2(controller_local_pos.x, controller_local_pos.y)

	var overlay_size = OverlayInit.ovr_interface.get_render_targetsize()
	# scale to pixels
	pos *= overlay_size.x
	pos /= get_parent().width_meters
	# adjust to center
	pos.y *= -1
	pos += overlay_size * 0.5
	return pos


func _update_cursor():
	_cursor_node.rect_position = get_canvas_pos()


func _send_click_event(state: bool):
	var click_event = InputEventMouseButton.new()
	click_event.position = get_canvas_pos()
	click_event.pressed = state
	click_event.button_index = 1
	viewport.input(click_event)


func _trigger_on(controller):
	if _touch_state:
		_active_controller = controller
		_trigger_state = true
		_send_click_event(true)
		emit_signal("trigger_on")


func _trigger_off():
	_trigger_state = false
	_send_click_event(false)
	emit_signal("trigger_off")


func _on_OverlayArea_entered(body: Node) -> void:
	if body.get_node("../../..") != self or is_moving:
		return
	_touch_state = true
	if not is_moving:
		_active_controller = body.get_parent()
	emit_signal("touch_on")


func _on_OverlayArea_exited(body: Node) -> void:
	if body.get_node("../../..") != self or is_moving:
		return
	# TEMP
	_active_controller = null # TODO revert to other controller if both were touching (edge case)
	_touch_state = false
	emit_signal("touch_off")


func _update_width():
	var ratio = OverlayInit.ovr_interface.get_render_targetsize()
	var extents = get_parent().width_meters * 0.5
	_overlay_area.get_child(0).shape.set_extents(Vector3(extents, extents * ratio.y/ratio.x, 0.1))


func _update_offset():
	_overlay_area.translation = get_parent().translation
	_overlay_area.rotation = get_parent().rotation


func _update_target():
	# move _overlay_area
	_overlay_area.get_parent().remove_child(_overlay_area)
	tracker_nodes[get_parent().current_target].add_child(_overlay_area)
#	match get_parent().target:
#		"head":
#			$VR/Head.add_child(_overlay_area)
#		"left":
#			$VR/LeftHand.add_child(_overlay_area)
#		"right":
#			$VR/RightHand.add_child(_overlay_area)
#		"world":
#			$VR.add_child(_overlay_area)

#	if is_moving:
#		return

	_left_is_activator = get_parent().current_target != "left"
	_right_is_activator = get_parent().current_target != "right"
	# toggle appropriate colliders
	$VR/left/OverlayActivator/Collision.disabled = !_left_is_activator
	$VR/right/OverlayActivator/Collision.disabled = !_right_is_activator


func _on_RightHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _right_is_activator:
		_trigger_on(tracker_nodes.right)


func _on_RightHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == tracker_nodes.right:
		_trigger_off()


func _on_LeftHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _left_is_activator:
		_trigger_on(tracker_nodes.left)


func _on_LeftHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == tracker_nodes.right:
		 _trigger_off()


func get_touch_state():
	return _touch_state


func get_trigger_state():
	return _trigger_state


func get_active_controller():
	return _active_controller

