extends Label

var _delay = 0


func _process(delta: float) -> void:
	_delay += delta
	if _delay > 1:
		update_text()
		_delay = 0


func update_text():
	var l = "??"
	var r = "??"

	if OverlayInit.left_id:
		l = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.left_id)
		l = str(int(l * 100))
		if OverlayInit.ovr_config.is_device_charging(OverlayInit.left_id):
			l += "+"

	if OverlayInit.right_id:
		r = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.right_id)
		r = str(int(r * 100))
		if OverlayInit.ovr_config.is_device_charging(OverlayInit.right_id):
			r += "+"

	text = "L: " + l + "% R: " + r + "%"
