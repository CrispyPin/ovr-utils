extends Spatial

var size : Vector2

func _init() -> void:
    #pass
#func _ready() -> void:
    var OpenVRConfig = preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()
    OpenVRConfig.set_application_type(2) # Set to OVERLAY MODE = 2, NORMAL MODE = 1
    OpenVRConfig.set_tracking_universe(1) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2

    # Find the OpenVR interface and initialise it
    var arvr_interface : ARVRInterface = ARVRServer.find_interface("OpenVR")

    if arvr_interface and arvr_interface.initialize():
        size = arvr_interface.get_render_targetsize()

func _ready() -> void:
    $Viewport.size = size
    #$VRViewport.size = size

