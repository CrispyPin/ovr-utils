extends Node

signal settings_saved
signal settings_loaded # emitted when settings are loaded from file, needs to be connected in _init()

var DEBUG_SETTINGS = true
var SETTINGS_PATH = "user://settings.json"
const SETTINGS_DEF = preload("res://addons/settings-manager/settings_definition.gd").DEF

var s: Dictionary = {}


func _ready() -> void:
	_init_settings()
	load_settings()
	save_settings()


func _init_settings() -> void:
	for key in SETTINGS_DEF:
		s[key] = _init_sub_setting(SETTINGS_DEF[key])
	if DEBUG_SETTINGS:
		print("Default settings: ", s)


func _init_sub_setting(def):
	match def.type:
		"dict":
			if has_flag(def, "resize"):
				return def.default
			var _s = {}
			for key in def.definition:
				_s[key] = _init_sub_setting(def.definition[key])
			return _s
		_:
			return def.default


func save_settings():
	var to_save = {}
	for key in s:
		var val = _save_sub_setting(s[key], SETTINGS_DEF[key])
		if val != null:
			to_save[key] = val

	var file = File.new()
	file.open(SETTINGS_PATH, File.WRITE)
	file.store_line(to_json(to_save))
	file.close()
	emit_signal("settings_saved")


func _save_sub_setting(val, def):
	if has_flag(def, "no_save"):
		return null

	match def.type:
		"vector2":
			return [val.x, val.y]
		"vector3":
			return [val.x, val.y, val.z]
		"quat":
			return [val.x, val.y, val.z, val.w]
		"dict":
			var resize = has_flag(def, "resize")
			var _s = {}
			for key in val:
				var subdef = def.definition if resize else def.definition[key]
				var v = _save_sub_setting(val[key], subdef)
				if v != null:
					_s[key] = v
			return _s
		_:
			return val


func load_settings() -> void:
	var file = File.new()

	if not file.file_exists(SETTINGS_PATH):
		if DEBUG_SETTINGS:
			print("No settings file exists, using defaults")
		return

	file.open(SETTINGS_PATH, File.READ)
	var new_settings = parse_json(file.get_as_text())
	file.close()

	for key in new_settings:
		s[key] = _load_sub_setting(new_settings[key], SETTINGS_DEF[key])

	emit_signal("settings_loaded")
	if DEBUG_SETTINGS:
		print("Loaded settings from file")
		print(s)


func _load_sub_setting(val, def):
	match def.type:
		"vector2":
			return Vector2(val[0], val[1])
		"vector3":
			return Vector3(val[0], val[1], val[2])
		"quat":
			return Quat(val[0], val[1], val[2], val[3])
		"dict":
			var _s = {}
			var resize = has_flag(def, "resize")
			for key in val:
				var subdef = def.definition if resize else def.definition[key]
				_s[key] = _load_sub_setting(val[key], subdef)
			return _s
		_:
			return val


func has_flag(def, flag):
	return def.has("flags") and flag in def.flags


func _exit_tree() -> void:
	# save on quit
	save_settings()


func _on_AutosaveTimer_timeout() -> void:
	# auto saves every 5 minutes, saving should also be done manually
	save_settings()
