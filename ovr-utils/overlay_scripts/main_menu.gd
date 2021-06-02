extends Control


func _ready() -> void:
	get_node("/root/Main/OverlayManager").connect("added_overlay", self, "_add_overlay_to_list")
	for o in Settings.s.overlays:
		_add_overlay_to_list(o)
	$VSplitContainer/Control/Overlays.visible = false


func _add_overlay_to_list(name):
	var new = preload("res://ui/ListOverlayItem.tscn").instance()
	new.overlay_name = name
	$VSplitContainer/Control/Overlays.add_child(new)



func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	Settings.emit_signal("settings_changed")


func _on_ShowOverlays_toggled(state: bool) -> void:
	$VSplitContainer/Control/Overlays.visible = state


func _on_AddOverlay_pressed() -> void:
	$VSplitContainer/Control/AddMenu.visible = true

