extends Control


func _ready() -> void:
	$VSplitContainer/Control/Overlays.visible = false


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	Settings.emit_signal("settings_changed")


func _on_ShowOverlays_toggled(state: bool) -> void:
	$VSplitContainer/Control/Overlays.visible = state
