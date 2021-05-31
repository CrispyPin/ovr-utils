extends PanelContainer

export var overlay_name: String
var overlay

func _ready() -> void:
	overlay = get_node("/root/Main/OverlayManager").get_node(overlay_name)
	$Label.text = overlay_name
	$HBoxContainer/Target.selected = overlay.TARGETS.find(overlay.target)


func _on_Visibility_toggled(state: bool) -> void:
	overlay.overlay_visible = state
	if state:
		$HBoxContainer/Visibility.icon = preload("res://icons/visible.svg")
	else:
		$HBoxContainer/Visibility.icon = preload("res://icons/hidden.svg")


func _on_Target_item_selected(index: int) -> void:
	overlay.target = overlay.TARGETS[index]


func _on_Reset_pressed() -> void:
	overlay.reset_offset()


func _on_Grab_toggled(state: bool) -> void:
	overlay.get_node("OverlayInteraction").grab_mode = state
