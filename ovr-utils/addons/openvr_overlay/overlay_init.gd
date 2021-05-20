extends Node

var ovr_interface: ARVRInterface
var ovr_config := preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()

var left_id = 0
var right_id = 0

func _init() -> void:
	ovr_config = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
	ovr_config.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
	ovr_config.set_tracking_universe(1) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2

	# Find the OpenVR interface and initialise it
	ovr_interface = ARVRServer.find_interface("OpenVR")
	if ovr_interface and ovr_interface.initialize():
		pass


func _ready() -> void:
	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")
	update_hand_ids()

func _tracker_changed(tracker_name: String, type: int, id: int):
	update_hand_ids()

func update_hand_ids():
	for i in ARVRServer.get_tracker_count():
		var tracker = ARVRServer.get_tracker(i)
#		print(tracker.get_name(), ": hand ", tracker.get_hand())

		var tracking_id = tracker.get_name().split("_")[-1]
		if tracker.get_hand() == 1:
			left_id = tracking_id
		elif tracker.get_hand() == 2:
			right_id = tracking_id
