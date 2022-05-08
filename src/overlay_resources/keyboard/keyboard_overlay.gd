extends Control

const OVERLAY_PROPERTIES = {
	"touchable": true,
}

export var key_size := 100
export var key_row : PackedScene
export var key_button : PackedScene
export var row_container_path : NodePath

var row_container

var keymap := {}
var toggle_keys := []

func _ready():
	row_container = get_node(row_container_path)
	load_keys("res://overlay_resources/keyboard/layouts/layout_se.json")


func load_keys(fp: String):
	var file = File.new()
	file.open(fp, File.READ)
	keymap = parse_json(file.get_as_text())
	file.close()
	
	apply_keys()


func apply_keys():
	for row in keymap.rows:
		var row_box = key_row.instance()
		row_container.add_child(row_box)
		for key in row.keys:
			var btn = key_button.instance()
			
			if not key.has("display"):
				key.display = key.keycode
			btn.get_node("Label").text = key.display
			btn.name = key.keycode
			
			btn.rect_min_size.x = key_size
			btn.rect_min_size.y = key_size
			if key.has("width"):
				btn.rect_min_size.x *= key.width
			
			if key.has("toggle") and key.toggle:
				btn.toggle_mode = true
				btn.connect("toggled", self, "key_toggled", [key.keycode])
				toggle_keys.append(btn)
			else:
				btn.connect("button_down", self, "key_down", [key.keycode])
				btn.connect("button_up", self, "key_up", [key.keycode])
				
			row_box.add_child(btn)
			
			# horizontal gaps
			if key.has("gap"):
				var gapbox = Control.new()
				gapbox.rect_min_size.x = key.gap * key_size
				gapbox.name = "Gap"
				row_box.add_child(gapbox)

		# vertical gaps
		if row.has("gap") and row.gap > 0:
			var gapbox = Control.new()
			gapbox.rect_min_size.y = row.gap * key_size
			gapbox.name = "Gap"
			row_container.add_child(gapbox)


func key_toggled(state, code):
	if state:
		GDVK.key_down(code)
	else:
		GDVK.key_up(code)


func key_down(code):
	GDVK.key_down(code)


func key_up(code):
	GDVK.key_up(code)
	# clear all modifier keys
	for k in toggle_keys:
		if k.pressed:
			k.pressed = false
	
