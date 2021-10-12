extends Node


var cursor_node  = preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance()
onready var viewport: Viewport = get_node("../../OverlayViewport")
onready var _i = get_parent()

var curr_pos: Vector2
var prev_pos := Vector2(-1000, 1000)

func _ready() -> void:
	viewport.add_child(cursor_node)
	get_parent().connect("trigger_on", self, "_trigger_on")
	get_parent().connect("trigger_off", self, "_trigger_off")


func _process(_delta: float) -> void:
	curr_pos = get_canvas_pos()
	_update_cursor()
	_send_move_event()
	prev_pos = curr_pos


#get canvas position of active controller
func get_canvas_pos() -> Vector2:
	var active
	if _i.state.right.near:
		active = "right"
	elif _i.state.left.near:
		active = "left"
	else:
		return Vector2(-1000, 1000) # offscreen
	#if not (_i.state.right.near or _i.state.left.near):

	var controller_local_pos = _i._overlay_area.global_transform.xform_inv(\
			_i.tracker_nodes[active].translation)
	var pos = Vector2(controller_local_pos.x, controller_local_pos.y)

	var overlay_size = Vector2(2048, 2048)
	# scale to pixels
	pos *= overlay_size.x
	pos /= _i.get_parent().width_meters
	# adjust to center
	pos.y *= -1
	pos += overlay_size * 0.5
	return pos


func _update_cursor():
	cursor_node.rect_position = get_canvas_pos()


func _send_move_event():
	var event = InputEventMouseMotion.new()
	event.position = prev_pos
	event.relative = curr_pos - prev_pos
	event.speed = event.relative
	viewport.input(event)



func _send_click_event(state: bool):
	var click_event = InputEventMouseButton.new()
	click_event.position = curr_pos
	click_event.pressed = state
	click_event.button_index = 1
	viewport.input(click_event)


func _trigger_on(controller):
	_send_click_event(true)


func _trigger_off(controller):
	_send_click_event(false)

