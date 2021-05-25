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

	if OverlayInit.trackers.left != -1:
		l = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.trackers.left)
		l = str(int(l * 100))
		if OverlayInit.ovr_config.is_device_charging(OverlayInit.trackers.left):
			l += "+"

	if OverlayInit.trackers.right != -1:
		r = OverlayInit.ovr_config.get_device_battery_percentage(OverlayInit.trackers.right)
		r = str(int(r * 100))
		if OverlayInit.ovr_config.is_device_charging(OverlayInit.trackers.right):
			r += "+"

	text = "L: " + l + "% R: " + r + "%"
