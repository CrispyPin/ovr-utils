extends Control

const OVERLAY_PROPERTIES = {
	"allow_hide": false,
	"allow_delete": false,
	"has_cursor": true,
	"has_grab": true,
}


func _ready() -> void:
	OverlayManager.connect("added_overlay", self, "_add_overlay_to_list")
	OverlayManager.connect("removed_overlay", self, "_remove_overlay_from_list")
	for o in Settings.s.overlays:
		if o != "MainOverlay":
			_add_overlay_to_list(o)
	$MarginContainer/VSplitContainer/Control/Overlays.visible = false


func _add_overlay_to_list(name):
	var new = preload("res://ui/ListOverlayItem.tscn").instance()
	new.overlay_name = name
	$MarginContainer/VSplitContainer/Control/Overlays.add_child(new)


func _remove_overlay_from_list(name):
	$MarginContainer/VSplitContainer/Control/Overlays.get_node(name).queue_free()


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	OverlayManager.emit_signal("grab_mode_changed")


func _on_ShowOverlays_toggled(state: bool) -> void:
	$MarginContainer/VSplitContainer/Control/Overlays.visible = state


func _on_AddOverlay_toggled(state: bool) -> void:
	$MarginContainer/VSplitContainer/Control/AddMenu.visible = state


func _on_QuitToggle_toggled(state: bool) -> void:
	$MarginContainer/VSplitContainer/MainBar/QuitToggle/Quit.visible = state


func _on_Quit_pressed() -> void:
	Settings.force_save()
	get_tree().quit()


func _on_add_menu_closed() -> void:
	$MarginContainer/VSplitContainer/MainBar/AddOverlay.pressed = false
