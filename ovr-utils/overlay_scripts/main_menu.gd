extends Control


func _ready() -> void:
	pass


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	Settings.emit_signal("settings_changed")
