extends Node


var is_moving := false

var _pre_move_target = ""# what offset is being changed
var _mover_hand_name = ""# left or right, which hand is grabbing (/active controller)
var _mover_hand_offsets = {"pos": Vector3(), "rot": Quat()} # original offsets for grabbing hand

onready var _overlay = get_node("../..") # overlay instance
onready var _interaction = get_parent() # interaction handler
onready var tracker_nodes = {
	"head":  $"../VR/head",
	"left":  $"../VR/left",
	"right": $"../VR/right",
	"world": $"../VR"
}


func _ready() -> void:
	get_parent().connect("trigger_on", self, "_trigger_on")
	get_parent().connect("trigger_off", self, "_trigger_off")


func _trigger_on(controller):
	if Settings.s.grab_mode or _interaction.grab_mode:
		begin_move(controller)


func _trigger_off(_controller):
	finish_move()


func begin_move(controller="right"):
	if not _interaction.state[controller].near:
		print("Could not begin moving overlay, " + controller + " controller is not touching overlay. <", _overlay.name, ">")
		return
	if is_moving:
		return
	is_moving = true
	_interaction.pause_triggers = true
	# store current states to revert after move
	_pre_move_target = _overlay.current_target
	_mover_hand_name = controller
	_mover_hand_offsets = _overlay.get_offset(_mover_hand_name)

	# calculate offsets from active controller to overlay
	var controller_t = tracker_nodes[_mover_hand_name].transform
	var overlay_t = _interaction._overlay_area.global_transform

	var new_pos = controller_t.xform_inv(overlay_t.origin)
	var new_rot = Quat(controller_t.basis).inverse() * Quat(overlay_t.basis)

	_overlay.set_offset(_mover_hand_name, new_pos, new_rot)
	_overlay.current_target = _mover_hand_name


func finish_move():
	if not is_moving:
		return
	is_moving = false
	# calculate and apply the new offsets
	var new_target_t = tracker_nodes[_pre_move_target].transform
	var ovelay_t = _interaction._overlay_area.global_transform

	var new_pos = new_target_t.xform_inv(ovelay_t.origin)
	var new_rot = Quat(new_target_t.basis).inverse() * Quat(ovelay_t.basis)

	_overlay.set_offset(_pre_move_target, new_pos, new_rot)

	# revert the grabbing hands offsets
	_overlay.set_offset(_mover_hand_name, _mover_hand_offsets.pos, _mover_hand_offsets.rot)

	# revert target
	_overlay.update_current_target()

	_interaction._update_target()
	_interaction.pause_triggers = false
