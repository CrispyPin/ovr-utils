extends Control

const OVERLAY_PROPERTIES = {
	"has_cursor": true,
}

var ihandler
var oinst


func _ready() -> void:
	oinst = get_viewport().get_parent()
	ihandler = get_viewport().get_node("../OverlayInteraction/OverlayGrab")
	#if not oinst.add_cursor:
	#	oinst.add_cursor()
	for t in oinst.TARGETS:
		$OptionButton.add_item(t)
	$OptionButton.selected = oinst.TARGETS.find(oinst.target)


func _on_DragButton_button_down() -> void:
	ihandler.begin_move()


func _on_DragButton_button_up() -> void:
	ihandler.finish_move()


func _on_OptionButton_item_selected(index: int) -> void:
	oinst.target = oinst.TARGETS[index]
