extends Label


func _ready() -> void:
    pass

func _process(delta: float) -> void:
    text = "%s:%s" % [OS.get_time().hour, OS.get_time().minute]
