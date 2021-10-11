extends Node

signal touch_on   # a controller entered
signal touch_off  # a controller exited
signal trigger_on # trigger pushed while touching
signal trigger_off# trigger released

var touch_state   := false
var trigger_state := false
var grab_mode := false setget set_grab_mode

# controller that currently has the trigger down
var active_controller := ""
# reference to the area node thats used for touch
var _overlay_area = preload("res://addons/openvr_overlay/interaction/OverlayArea.tscn").instance()
var _right_is_activator := false # this hand has a collider on it to trigger things on the overlay
var _left_is_activator  := false

var pause_triggers := false # disable triggers updating

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
	get_parent().connect("path_changed", self, "_update_modules")
	get_parent().connect("path_changed", self, "_update_target")

	OverlayManager.connect("grab_mode_changed", self, "update_selection")

	_update_width()
	_update_offset()
	_update_target()


func _trigger_on(controller):
	if touch_state:
		active_controller = controller
		trigger_state = true
		emit_signal("trigger_on")


func _trigger_off():
	trigger_state = false
	emit_signal("trigger_off")


func _on_OverlayArea_entered(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	touch_state = true
	active_controller = body.get_parent().name
	update_selection()
	emit_signal("touch_on")


func _on_OverlayArea_exited(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	active_controller = ""
	touch_state = false
	update_selection()
	emit_signal("touch_off")


func update_selection():
	var sel = touch_state and (Settings.s.grab_mode or grab_mode)
	get_parent().get_node("OverlayViewport/Selected").visible = sel


func set_grab_mode(state: bool) -> void:
	grab_mode = state
	update_selection()


func _update_width():
	var ratio = OverlayInit.ovr_interface.get_render_targetsize()
	var extents = get_parent().width_meters * 0.5
	_overlay_area.get_child(0).shape.set_extents(Vector3(extents, extents * ratio.y/ratio.x, 0.05))


func _update_offset():
	_overlay_area.translation = get_parent().translation
	_overlay_area.rotation = get_parent().rotation


func _update_target():
	var t = get_parent().current_target
	# reparent _overlay_area
	_overlay_area.get_parent().remove_child(_overlay_area)
	tracker_nodes[t].add_child(_overlay_area)

	_left_is_activator = t != "left"
	_right_is_activator = t != "right"
	# make area only detect colliders of a different hand
	_overlay_area.collision_mask = int(t!="right")*2 # detect right hand
	_overlay_area.collision_mask += int(t!="left")*4 # detect left hand


func _update_modules():
	# this should be handled better, DRY
	# grab module
	var grab_module_exists: bool = get_node_or_null("OverlayGrab") != null

	if get_parent().get_property("has_grab"):
		if !grab_module_exists:
			var module = preload("res://addons/openvr_overlay/OverlayGrab.tscn")
			add_child(module.instance())
	elif grab_module_exists:
		get_node("OverlayGrab").queue_free()

	# cursor module
	var cursor_module_exists: bool = get_node_or_null("OverlayCursor") != null

	if get_parent().get_property("has_cursor"):
		if !cursor_module_exists:
			var module = preload("res://addons/openvr_overlay/OverlayCursor.tscn")
			add_child(module.instance())
	elif cursor_module_exists:
		get_node("OverlayCursor").queue_free()



func _on_RightHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _right_is_activator:
		_trigger_on("right")


func _on_RightHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and active_controller == "right":
		_trigger_off()


func _on_LeftHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _left_is_activator:
		_trigger_on("left")


func _on_LeftHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and active_controller == "left":
		 _trigger_off()
