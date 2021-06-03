extends PanelContainer

export var overlay_name: String
var overlay

func _ready() -> void:
	overlay = OverlayManager.get_node(overlay_name)
	$Label.text = overlay_name
	name = overlay_name
	$HBoxContainer/Target.selected = overlay.TARGETS.find(Settings.s.overlays[overlay_name].target)
	overlay.connect("overlay_visibility_changed", self, "_overlay_visibility_changed")


func _on_Visibility_toggled(state: bool) -> void:
	if overlay.type and overlay.type != "main":
		overlay.overlay_visible = state


func _on_Target_item_selected(index: int) -> void:
	overlay.target = overlay.TARGETS[index]


func _on_Reset_pressed() -> void:
	overlay.reset_offset()


func _on_Grab_toggled(state: bool) -> void:
	overlay.get_node("OverlayInteraction").grab_mode = state


func _overlay_visibility_changed(state: bool):
	$HBoxContainer/Visibility.pressed = state
	if state:
		$HBoxContainer/Visibility.icon = preload("res://icons/visible.svg")
	else:
		$HBoxContainer/Visibility.icon = preload("res://icons/hidden.svg")


func _on_Remove_pressed() -> void:
	if overlay.type and overlay.type != "main":
		OverlayManager.remove_overlay(overlay_name)

