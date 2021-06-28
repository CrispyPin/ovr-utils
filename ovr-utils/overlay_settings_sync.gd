extends Node


onready var p = get_parent()
var loaded := false
var _needs_sync := true

func _ready() -> void:
	p = get_parent()
	call_deferred("load_all")
	p.connect("path_changed",            self, "_prop_changed")
	p.connect("overlay_visible_changed", self, "_prop_changed")
	p.connect("width_changed",           self, "_prop_changed")
	p.connect("alpha_changed",           self, "_prop_changed")
	p.connect("target_changed",          self, "_prop_changed")
	p.connect("fallback_changed",        self, "_prop_changed")
	p.connect("offset_changed",          self, "_prop_changed")


func _prop_changed(_val=null):
	_needs_sync = true


func save_all() -> void:
	if not loaded:
		return
	if not Settings.s.overlays.has(p.name):
		Settings.s.overlays[p.name] = {}
	_save_prop("path",     p.path)
	_save_prop("visible",  p.overlay_visible)
	_save_prop("width",    p.width_meters)
	_save_prop("alpha",    p.alpha)
	_save_prop("target",   p.target)
	_save_prop("fallback", p.fallback)
	_save_prop("offsets",  p._offsets.duplicate(true))
	_needs_sync = false


func _save_prop(prop_name: String, prop_value) -> void:
	Settings.s.overlays[p.name][prop_name] = prop_value


func load_all() -> void:
	if Settings.s.overlays.has(p.name):
		var new = Settings.s.overlays[p.name]

		if new.has("path"):
			p.path = new.path
		if new.has("visible"):
			p.overlay_visible = new.visible
		if new.has("width"):
			p.width_meters = new.width
		if new.has("alpha"):
			p.alpha = new.alpha
		if new.has("target"):
			p.target = new.target
		if new.has("fallback"):
			p.fallback = new.fallback

		if new.has("offsets"):# thorough in case some values are missing in file
			for t_key in new.offsets:
				var offset = new.offsets[t_key]
				p.set_offset(t_key, offset.pos, offset.rot)

	else:
		print("FAILED to load settings")
		save_all()
	loaded = true


func _on_SyncTimer_timeout() -> void:
	if _needs_sync:
		save_all()

