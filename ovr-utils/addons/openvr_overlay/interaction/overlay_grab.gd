extends Node


var _pre_move_target = ""# what offset is being changed
var _mover_hand_name = ""# left or right, which hand is grabbing (/active controller)
var _mover_hand_offsets = {"pos": Vector3(), "rot": Quat()} # original offsets for grabbing hand


onready var _i = get_parent()
onready var tracker_nodes = {
	"head":  $"../VR/head",
	"left":  $"../VR/left",
	"right": $"../VR/right",
	"world": $"../VR"
}
onready var _overlay_area = _i._overlay_area

onready var _overlay = get_node("../..")


func _ready() -> void:
	pass


func begin_move():
	if not _i._active_controller:
		print("Could not begin moving overlay, no controller active. ", _overlay.name)
		return
	_i.pause_triggers = true
	# store current states to revert after move
	_pre_move_target = _overlay.current_target
	_mover_hand_name = _i._active_controller
	_mover_hand_offsets = _overlay.get_offset_dict(_mover_hand_name)

	# calculate offsets from active controller to overlay
	var controller_t = tracker_nodes[_i._active_controller].transform
	var overlay_t = _i._overlay_area.global_transform

	var new_pos = controller_t.xform_inv(overlay_t.origin)
	var new_rot = Quat(controller_t.basis).inverse() * Quat(overlay_t.basis)
	_overlay.set_offset(_mover_hand_name, new_pos, new_rot)

	_overlay.current_target = _mover_hand_name



func finish_move():
	# calculate and apply the new offsets
	var new_target_t = tracker_nodes[_pre_move_target].transform
	var ovelay_t = _overlay_area.global_transform

	var new_pos = new_target_t.xform_inv(ovelay_t.origin)
	var new_rot = Quat(new_target_t.basis).inverse() * Quat(ovelay_t.basis)
	_overlay.set_offset(_pre_move_target, new_pos, new_rot)

	# revert the grabbing hands offsets in case it's used as a fallback
	_overlay.set_offset_dict(_mover_hand_name, _mover_hand_offsets)

	# reset current_target (parent handles fallback)
	_overlay.update_current_target()
	_overlay.save_settings()

	_i._update_target()
	_i.pause_triggers = false
