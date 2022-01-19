extends Control

const OVERLAY_PROPERTIES = {
	"has_touch": true,
}

export var key_size := 128
export var key_row : PackedScene
export var key_button : PackedScene

var keymap := {}

func _ready():
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
		$PanelContainer/CenterContainer/VBoxContainer.add_child(row_box)
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
				
			row_box.add_child(btn)
			btn.connect("pressed", self, "key_pressed", [key.keycode])
			
			# horizontal gaps
			if key.has("gap"):
				var gapbox = Control.new()
				gapbox.rect_min_size.x = key.gap * key_size
				gapbox.name = "Gap"
				row_box.add_child(gapbox)
		# vertical gaps
		if row.has("gap"):
			var gapbox = Control.new()
			gapbox.rect_min_size.y = row.gap * key_size
			gapbox.name = "Gap"
			$PanelContainer/CenterContainer/VBoxContainer.add_child(gapbox)


func key_pressed(code, toggle=false):
	GDVK.press(code)
	

