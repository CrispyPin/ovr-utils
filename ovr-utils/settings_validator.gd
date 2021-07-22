extends Node


static func is_valid(to_check: Dictionary) -> bool:
	if not to_check.has("version"):
		return false
	return to_check.version == preload("res://settings_definition.gd").VERSION
