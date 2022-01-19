extends Node

export var is_touch := false

onready var viewport: Viewport = get_node("../../OverlayViewport")
onready var _i = get_parent()

var cursor_pos := {
	"right": Vector2(),
	"left": Vector2(),
}
var prev_pos := {
	"right": Vector2(),
	"left": Vector2(),
}
var click := {
	"right": false,
	"left": false,
}
var active_side := ""

var cursor_nodes := {
	"right": preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance(),
	"left": preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance(),
}
var temp = 0
var tstate = true

func _ready() -> void:
	viewport.add_child(cursor_nodes.right)
	viewport.add_child(cursor_nodes.left)
	if is_touch:
		get_parent().connect("touch_on", self, "_trigger_on")
		get_parent().connect("touch_off", self, "_trigger_off")
	else:
		get_parent().connect("trigger_on", self, "_trigger_on")
		get_parent().connect("trigger_off", self, "_trigger_off")
	

func _process(delta: float) -> void:
	cursor_pos.right = get_canvas_pos("right")
	cursor_pos.left = get_canvas_pos("left")
	_update_cursors()
	#_send_move_event()
	prev_pos = cursor_pos.duplicate(true)
#	if is_touch:
#		temp += delta
#		if temp > 0.5:
#			temp = 0
#			var click_event = InputEventMouseButton.new()
#			click_event.position = Vector2(240, 340)
#			click_event.pressed = tstate
#			tstate = !tstate
#			click_event.button_index = 1
#			viewport.input(click_event)
#			print("SENT EVENT ", click_event.position, " -- ", click_event.pressed)
##			viewport.


#get canvas position of controller
func get_canvas_pos(controller) -> Vector2:
	var controller_local_pos = _i._overlay_area.global_transform.xform_inv(\
			_i.tracker_nodes[controller].translation)
	var pos = Vector2(controller_local_pos.x, controller_local_pos.y)

	var overlay_size = Vector2(2048, 2048)
	# scale to pixels
	pos *= overlay_size.x
	pos /= _i.get_parent().width_meters
	# adjust to center
	pos.y *= -1
	pos += overlay_size * 0.5
	return pos


func _update_cursors():
	cursor_nodes.right.visible = _i.state.right.near
	cursor_nodes.left.visible = _i.state.left.near
	cursor_nodes.right.rect_position = cursor_pos.right
	cursor_nodes.left.rect_position = cursor_pos.left


func _send_move_event():
	if not active_side:
		return# only send move events while a cursor is held down
	
	var event = InputEventMouseMotion.new()
	event.position = prev_pos[active_side]
	event.relative = cursor_pos[active_side] - prev_pos[active_side]
	event.speed = event.relative
	viewport.input(event)


func _send_click_event(state: bool, controller: String):
	if click[controller] == state:
		return # already in that state
	click[controller] = state
	_update_active_side()
	var click_event = InputEventMouseButton.new()
	click_event.position = cursor_pos[controller]
	click_event.pressed = state
	click_event.button_index = 1
	viewport.input(click_event)
#	print("SENT EVENT ", click_event.position, " -- ", click_event.pressed)


func _trigger_on(controller):
	if click.right or click.left:
		return
	_send_click_event(true, controller)


func _trigger_off(controller):
	_send_click_event(false, controller)

func _update_active_side() -> void:
	if click.right:
		active_side = "right"
	elif click.left:
		active_side = "left"
	else:
		active_side = ""
