extends Label


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	_update_time()


func _update_time():
	var h = str(OS.get_time().hour)
	var m = str(OS.get_time().minute)
	h = h if len(h) == 2 else "0" + h
	m = m if len(m) == 2 else "0" + m
	text = h + ":" + m
