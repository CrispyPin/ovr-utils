extends Control


func _ready() -> void:
	get_viewport().get_parent().add_cursor()


func _on_Open_pressed() -> void:
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path: String) -> void:
#	var img = load(path)
	var tex = ImageTexture.new()
	tex.load(path)
	$Image.texture = tex


func _on_FileDialog_dir_selected(dir: String) -> void:
	print(dir)
	$FileDialog.current_dir = dir
	$FileDialog.call_deferred("show")
