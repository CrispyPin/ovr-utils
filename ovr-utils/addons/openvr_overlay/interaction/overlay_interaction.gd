extends ARVROrigin

signal touch_on #  a controller entered
signal touch_off # a controller exited
signal trigger_on  # trigger pushed while touching
signal trigger_off # trigger released

export var active_theme: Theme
export var normal_theme: Theme
export var touching_theme: Theme

var active_controllers = []

var _touch_state = false setget ,get_touch_state
var _trigger_state = false setget ,get_trigger_state
var _active_controller: ARVRController = null setget ,get_active_controller

onready var panel = get_node("../OverlayViewport/PanelContainer")


func _ready() -> void:
	get_parent().connect("width_changed", self, "_on_width_changed")
	_on_width_changed(get_parent().width_meters)

	get_node("../OffsetInv").remote_path = $Offset.get_path()
	$Offset.remote_path = $LeftHand/Area.get_path()


func _process(delta: float) -> void:
	if _touch_state:
		if not _trigger_state:
			_get_trigger_down()
		else:
			_get_trigger_up()


func _get_trigger_down():
	for c in active_controllers:
		if c.is_button_pressed(JOY_VR_TRIGGER):
			_active_controller = c
			emit_signal("trigger_on")
			return


func _get_trigger_up():
	if not _active_controller.is_button_pressed(JOY_VR_TRIGGER):
		_active_controller = null
		emit_signal("trigger_off")


func _on_Area_body_entered(body: Node) -> void:
	if body.get_parent().get_parent() != self:
		return
	panel.theme = active_theme
	_touch_state = true
	emit_signal("touch_on")


func _on_Area_body_exited(body: Node) -> void:
	if body.get_parent().get_parent() != self:
		return
	panel.theme = normal_theme
	_touch_state = false
	emit_signal("touch_off")


func _on_width_changed(width):
	var ratio = OverlayInit.ovr_interface.get_render_targetsize()
	$LeftHand/Area/CollisionShape.shape.set_extents(Vector3(0.5*width, 0.5*width * ratio.y/ratio.x, 0.01))


func get_touch_state():
	return _touch_state


func get_trigger_state():
	return _trigger_state


func get_active_controller():
	return _active_controller

