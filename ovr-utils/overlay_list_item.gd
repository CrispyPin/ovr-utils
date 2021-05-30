extends PanelContainer

var overlay

func _ready() -> void:
	overlay = get_node("/root/Main/OverlayManager").get_child(1)


func _on_Visibility_toggled(state: bool) -> void:
	overlay.get_node("OverlayViewport").overlay_visible = state
	if state:
		$HBoxContainer/Visibility.icon = preload("res://icons/visible.svg")
	else:
		$HBoxContainer/Visibility.icon = preload("res://icons/hidden.svg")
