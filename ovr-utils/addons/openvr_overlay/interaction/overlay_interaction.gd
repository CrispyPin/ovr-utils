extends ARVROrigin

signal touch_on #  a controller entered
signal touch_off # a controller exited
signal trigger_on  # trigger pushed while touching
signal trigger_off # trigger released

export var active_theme: Theme
export var normal_theme: Theme
export var touching_theme: Theme

const OVERLAY_AREA = preload("res://addons/openvr_overlay/interaction/OverlayArea.tscn")

var _touch_state = false setget ,get_touch_state
var _trigger_state = false setget ,get_trigger_state

# controller that currently the  trigger down
var _active_controller: ARVRController setget ,get_active_controller
var _overlay_area: Area # reference to the area node thats used for touch
var _right_is_activator = false
var _left_is_activator = false


onready var panel = get_node("../OverlayViewport/PanelContainer")


func _ready() -> void:
	# TEMP
	_right_is_activator = true
	###############
	_overlay_area = OVERLAY_AREA.instance()
	add_child(_overlay_area)
	_overlay_area.connect("body_entered", self, "_on_OverlayArea_entered")
	_overlay_area.connect("body_exited", self, "_on_OverlayArea_exited")

	get_parent().connect("width_changed", self, "_update_width")
	get_parent().connect("offset_changed", self, "_update_offset")
	get_parent().connect("target_changed", self, "_update_target")

	_update_width()
	_update_offset()
	_update_target()


func _process(delta: float) -> void:
	pass


func _trigger_on(controller):
	if _touch_state:
		_active_controller = controller
		_trigger_state = true
		_update_selection()
		emit_signal("trigger_on")


func _trigger_off():
	_active_controller = null
	_trigger_state = false
	_update_selection()
	emit_signal("trigger_off")


func _on_OverlayArea_entered(body: Node) -> void:
	if body.get_parent().get_parent() != self:
		return
	_touch_state = true
	_update_selection()
	emit_signal("touch_on")


func _on_OverlayArea_exited(body: Node) -> void:
	if body.get_parent().get_parent() != self:
		return
	_touch_state = false
	_update_selection()
	emit_signal("touch_off")


func _update_selection():
	if _trigger_state:
		panel.theme = active_theme
	elif _touch_state:
		panel.theme = touching_theme
	else:
		panel.theme = normal_theme


func _update_width():
	var ratio = OverlayInit.ovr_interface.get_render_targetsize()
	var extents = get_parent().width_meters * 0.5
	_overlay_area.get_child(0).shape.set_extents(Vector3(extents, extents * ratio.y/ratio.x, 0.01))


func _update_offset():
	_overlay_area.translation = get_parent().offset_pos
	_overlay_area.rotation_degrees = get_parent().offset_rot


func _update_target():
	# move _overlay_area
	_overlay_area.get_parent().remove_child(_overlay_area)
	match get_parent().target:
		OverlayInstance.TARGETS.head:
			$Head.add_child(_overlay_area)
		OverlayInstance.TARGETS.left:
			$LeftHand.add_child(_overlay_area)
		OverlayInstance.TARGETS.right:
			$RightHand.add_child(_overlay_area)
		OverlayInstance.TARGETS.world:
			add_child(_overlay_area)

	_left_is_activator = get_parent().target != OverlayInstance.TARGETS.left
	_right_is_activator = get_parent().target != OverlayInstance.TARGETS.right
	# toggle appropriate colliders
	$LeftHand/OverlayActivator/Collision.disabled = !_left_is_activator
	$RightHand/OverlayActivator/Collision.disabled = !_right_is_activator


func _on_RightHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _right_is_activator:
		_trigger_on($RightHand)


func _on_RightHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == $RightHand:
		_trigger_off()


func _on_LeftHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and _left_is_activator:
		_trigger_on($LeftHand)


func _on_LeftHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and _active_controller == $LeftHand:
		 _trigger_off()


func get_touch_state():
	return _touch_state


func get_trigger_state():
	return _trigger_state


func get_active_controller():
	return _active_controller

