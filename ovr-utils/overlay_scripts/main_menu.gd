extends Control


func _ready() -> void:
	OverlayManager.connect("added_overlay", self, "_add_overlay_to_list")
	OverlayManager.connect("removed_overlay", self, "_remove_overlay_from_list")
	for o in Settings.s.overlays:
		if o != "MainOverlay":
			_add_overlay_to_list(o)
	$VSplitContainer/Control/Overlays.visible = false


func _add_overlay_to_list(name):
	var new = preload("res://ui/ListOverlayItem.tscn").instance()
	new.overlay_name = name
	$VSplitContainer/Control/Overlays.add_child(new)

func _remove_overlay_from_list(name):
	$VSplitContainer/Control/Overlays.get_node(name).queue_free()


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state


func _on_ShowOverlays_toggled(state: bool) -> void:
	$VSplitContainer/Control/Overlays.visible = state


func _on_AddOverlay_pressed() -> void:
	$VSplitContainer/Control/AddMenu.visible = !$VSplitContainer/Control/AddMenu.visible

