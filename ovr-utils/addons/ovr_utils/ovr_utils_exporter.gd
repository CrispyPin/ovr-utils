tool
extends EditorExportPlugin

func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int) -> void:
	ProjectSettings.set_setting("display/window/size/height", 16)
	ProjectSettings.set_setting("display/window/size/width", 16)
	ProjectSettings.save()

func _export_end() -> void:
	ProjectSettings.set_setting("display/window/size/height", 2048)
	ProjectSettings.set_setting("display/window/size/width", 2048)
	ProjectSettings.save()
