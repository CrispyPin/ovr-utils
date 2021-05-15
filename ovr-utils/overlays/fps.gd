extends Label


func _ready() -> void:
    pass

func _process(delta: float) -> void:
    if delta > 0:
        text = "Overlay FPS: " + str(round(1/delta))
