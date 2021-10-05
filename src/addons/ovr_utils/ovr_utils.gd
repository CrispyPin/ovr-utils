tool
extends EditorPlugin

var export_plugin


func _enter_tree():
	export_plugin = preload("res://addons/ovr_utils/ovr_utils_exporter.gd").new()
	add_export_plugin(export_plugin)


func _exit_tree():
	if export_plugin:
		remove_export_plugin(export_plugin)
