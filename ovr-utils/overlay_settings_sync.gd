extends Node


onready var p = get_parent()
var loaded := false

func _ready() -> void:
	p = get_parent()
	call_deferred("load_all")
	p.connect("type_changed",            self, "save_all")
	p.connect("overlay_visible_changed", self, "save_all")
	p.connect("width_changed",           self, "save_all")
	p.connect("alpha_changed",           self, "save_all")
	p.connect("target_changed",          self, "save_all")
	p.connect("fallback_changed",        self, "save_all")
	p.connect("offset_changed",          self, "save_all")


func save_all(_args=null) -> void:
	if not loaded:
		return
	if not Settings.s.overlays.has(p.name):
		Settings.s.overlays[p.name] = {}
	_save_prop("type",     p.type)
	_save_prop("visible",  p.overlay_visible)
	_save_prop("width",    p.width_meters)
	_save_prop("alpha",    p.alpha)
	_save_prop("target",   p.target)
	_save_prop("fallback", p.fallback)
	_save_prop("offsets",  p._offsets.duplicate(true))


func _save_prop(prop_name: String, prop_value) -> void:
	Settings.s.overlays[p.name][prop_name] = prop_value

func load_all() -> void:
	if Settings.s.overlays.has(p.name):
		var new = Settings.s.overlays[p.name]
		# type is assigned at creation

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
		print("FAILED")
		save_all()
	loaded = true
