extends Label

const OVERLAY_PROPERTIES = {

}

var _delay = 0


func _process(delta: float) -> void:
	_delay += delta
	if _delay > 0.2:
		update_time()
		_delay = 0


func update_time():
	var h = str(OS.get_time().hour)
	var m = str(OS.get_time().minute)
	h = h if len(h) == 2 else "0" + h
	m = m if len(m) == 2 else "0" + m
	text = h + ":" + m
