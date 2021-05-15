extends Node


func _ready() -> void:
    $OverlayInstance.offset_pos = Vector3(1,2,3)
    $OverlayInstance.offset_pos.x = 4

