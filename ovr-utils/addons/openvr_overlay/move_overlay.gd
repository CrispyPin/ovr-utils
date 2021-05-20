extends Control


var ihandler

func _ready() -> void:
	ihandler = get_viewport().get_node("../OverlayInteraction")


func _on_DragButton_button_down() -> void:
	if ihandler:
		ihandler.begin_move()


func _on_DragButton_button_up() -> void:
	if ihandler:
		ihandler.finish_move()
