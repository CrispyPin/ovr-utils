extends Control


func _ready() -> void:
	for o in Settings.s.overlays:
		var new = preload("res://ListOverlayItem.tscn").instance()
		new.overlay_name = o
		$VSplitContainer/Control/Overlays.add_child(new)
	$VSplitContainer/Control/Overlays.visible = false


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	Settings.emit_signal("settings_changed")


func _on_ShowOverlays_toggled(state: bool) -> void:
	$VSplitContainer/Control/Overlays.visible = state


func _on_AddOverlay_pressed() -> void:
	pass # Replace with function body.
