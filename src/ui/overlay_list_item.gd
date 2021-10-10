extends Control

export var overlay_name: String
var overlay

func _ready() -> void:
	overlay = OverlayManager.get_node(overlay_name)
	overlay.get_node("OverlaySettingsSync").connect("loaded_settings", self, "_apply_loaded")

	$MoreOptions/Container/List/SetSize/PanelContainer.visible = false
	$MoreOptions/Container/List/SetAlpha/PanelContainer.visible = false
	$MoreOptions.visible = false

	$BasicOptions/Label.text = overlay_name
	name = overlay_name
	overlay.connect("overlay_visible_changed", self, "_overlay_visible_changed")
	overlay.connect("path_changed", self, "_update_warning")


func _apply_loaded():
	$MoreOptions/Container/List/SetSize/PanelContainer/SizeSlider.value = overlay.width_meters
	$MoreOptions/Container/List/Target.selected = overlay.TARGETS.find(overlay.target)
	$MoreOptions/Container/List/SetAlpha/PanelContainer/AlphaSlider.value = overlay.alpha
	_overlay_visible_changed(overlay.overlay_visible)
	_update_warning()


func _update_warning():
	$BasicOptions/List/Warning.visible = overlay.path_invalid
	$BasicOptions/List/Warning/WarningInfo/Label.text = overlay.path + "\nnot found"


func _on_Visibility_toggled(state: bool) -> void:
	if overlay.get_property("allow_hide"):
		overlay.overlay_visible = state
	else:
		overlay.overlay_visible = true


func _on_Grab_toggled(state: bool) -> void:
	overlay.get_node("OverlayInteraction").grab_mode = state
	$BasicOptions/List/Grab.pressed = state
	$MoreOptions/Container/List/Grab.pressed = state


func _overlay_visible_changed(state: bool):
	$BasicOptions/List/Visibility.pressed = state
	if state:
		$BasicOptions/List/Visibility.icon = preload("res://icons/visible.svg")
	else:
		$BasicOptions/List/Visibility.icon = preload("res://icons/hidden.svg")


func _on_Remove_pressed() -> void:
	if overlay.get_property("allow_delete"):
		OverlayManager.remove_overlay(overlay_name)


func _on_Reset_pressed() -> void:
	overlay.reset_offset()
	_on_Grab_toggled(true)


func _on_Target_item_selected(index: int) -> void:
	overlay.target = overlay.TARGETS[index]


func _on_Options_pressed() -> void:
	$MoreOptions.visible = true


func _on_CloseOptions_pressed() -> void:
	$MoreOptions.visible = false


func _on_SetSize_toggled(state: bool) -> void:
	$MoreOptions/Container/List/SetSize/PanelContainer.visible = state


func _on_SetAlpha_toggled(state: bool) -> void:
	$MoreOptions/Container/List/SetAlpha/PanelContainer.visible = state


func _on_SizeSlider_value_changed(value: float) -> void:
	overlay.width_meters = value


func _on_AlphaSlider_value_changed(value: float) -> void:
	overlay.alpha = value


func _on_Warning_toggled(state: bool) -> void:
	$BasicOptions/List/Warning/WarningInfo.visible = state

