extends Node

var ovr_interface: ARVRInterface

func _init() -> void:
    var ovr_config = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
    ovr_config.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
    ovr_config.set_tracking_universe(1) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2

    # Find the OpenVR interface and initialise it
    ovr_interface = ARVRServer.find_interface("OpenVR")
    if ovr_interface and ovr_interface.initialize():
        pass

func _ready() -> void:
    for i in ARVRServer.get_tracker_count():
        var tracker = ARVRServer.get_tracker(i)
        print(tracker.get_name(), ": hand ",  tracker.get_hand())
