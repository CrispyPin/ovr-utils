extends Control

const OVERLAY_PROPERTIES = {
	"has_cursor": true,
	"has_touch": true,
}

var grabber
var clicker
var oinst


func _ready() -> void:
	oinst = get_viewport().get_parent()
	clicker = get_viewport().get_node("../OverlayInteraction/OverlayCursor")
	grabber = get_viewport().get_node("../OverlayInteraction/OverlayGrab")
	for t in oinst.TARGETS:
		$OptionButton.add_item(t)
	$OptionButton.selected = oinst.TARGETS.find(oinst.target)


func _on_DragButton_button_down() -> void:
	grabber.begin_move(clicker.active_side)


func _on_DragButton_button_up() -> void:
	grabber.finish_move()


func _on_OptionButton_item_selected(index: int) -> void:
	oinst.target = oinst.TARGETS[index]
