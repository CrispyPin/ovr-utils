extends Label

var _delay = 0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_delay += delta
	if _delay > 1:
		update_text()
		_delay = 0

func update_text():
	var l = "NaN"
	var r = "NaN"
	if OverlayInit.left_id:
		l = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.left_id)*100
		l = str(int(l))
	if OverlayInit.right_id:
		r = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.right_id)*100
		r = str(int(r))
		if OverlayInit.ovr_config.is_device_charging(OverlayInit.right_id):
			r += "+"
	text = "Left: " + l + "% Right: " + r + "%"
