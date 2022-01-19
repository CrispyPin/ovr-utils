extends Control

const OVERLAY_PROPERTIES = {
	"has_cursor": true,
}


func _ready() -> void:
	#get_viewport().get_parent().add_cursor()
	var homefolder = OS.get_user_data_dir()
	homefolder = homefolder.get_base_dir().get_base_dir().get_base_dir()
	$FileDialog.current_dir = homefolder


func _on_Open_pressed() -> void:
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path: String) -> void:
	var tex = ImageTexture.new()
	tex.load(path)
	$Image.texture = tex


func _on_FileDialog_dir_selected(dir: String) -> void:
	print(dir)
	$FileDialog.current_dir = dir
	$FileDialog.call_deferred("show")
