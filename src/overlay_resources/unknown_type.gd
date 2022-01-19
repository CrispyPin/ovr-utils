extends Control


func _ready() -> void:
	$Label.text += get_viewport().get_parent().path
