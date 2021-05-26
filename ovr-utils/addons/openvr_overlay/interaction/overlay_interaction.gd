extends Node

signal touch_on   # a controller entered
signal touch_off  # a controller exited
signal trigger_on # trigger pushed while touching
signal trigger_off# trigger released

var _touch_state   = false
var _trigger_state = false

# controller that currently the  trigger down
var _active_controller: String = ""
# reference to the area node thats used for touch
var _overlay_area = preload("res://addons/openvr_overlay/interaction/OverlayArea.tscn").instance()
var _right_is_activator := false
var _left_is_activator  := false

var pause_triggers := false

onready var tracker_nodes = {
	"head":  $VR/head,
	"left":  $VR/left,
	"right": $VR/right,
	"world": $VR
}


func _ready() -> void:

	add_child(_overlay_area)
	_overlay_area.connect("body_entered", self, "_on_OverlayArea_entered")
	_overlay_area.connect("body_exited", self, "_on_OverlayArea_exited")

	get_parent().connect("width_changed", self, "_update_width")
	get_parent().connect("offset_changed", self, "_update_offset")
	get_parent().connect("target_changed", self, "_update_target")

	_update_width()
	_update_offset()
	_update_target()


func _trigger_on(controller):
	if _touch_state:
		_active_controller = controller
		_trigger_state = true
		emit_signal("trigger_on")


func _trigger_off():
	_trigger_state = false
	emit_signal("trigger_off")


func _on_OverlayArea_entered(body: Node) -> void:
	if body.get_node("../../..") != self or pause_triggers:
		return
	_touch_state = true
	_active_controller = body.get_parent().name
	emit_signal("touch_on")


func _on_OverlayArea_exited(body: Node) -> void:
	if body.get_node("../../..") != self or pause_triggers:
		return
	# TEMP
	_active_controller = "" # TODO revert to other controller if both were touching (edge case)
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
	# reparent _overlay_area
	_overlay_area.get_parent().remove_child(_overlay_area)
	tracker_nodes[get_parent().current_target].add_child(_overlay_area)


	_left_is_activator = get_parent().current_target != "left"
	_right_is_activator = get_parent().current_target != "right"
	# toggle appropriate colliders
	$VR/left/OverlayActivator/Collision.disabled = !_left_is_activator
	$VR/right/OverlayActivator/Collision.disabled = !_right_is_activator


func _on_RightHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _right_is_activator:
		_trigger_on("right")


func _on_RightHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == "right":
		_trigger_off()


func _on_LeftHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _left_is_activator:
		_trigger_on("left")


func _on_LeftHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == "left":
		 _trigger_off()


func get_touch_state():
	return _touch_state


func get_trigger_state():
	return _trigger_state


func get_active_controller():
	return _active_controller

