extends Control

var ihandler

func _ready() -> void:
	ihandler = get_viewport().get_node("../OverlayInteraction")


func _on_DragButton_button_down() -> void:
	ihandler.begin_move()


func _on_DragButton_button_up() -> void:
	ihandler.finish_move()
