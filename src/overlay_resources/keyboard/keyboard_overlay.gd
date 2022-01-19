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
		#TODO gaps


func key_pressed(code, toggle=false):
	GDVK.press(code)
	


func _on_KeyO_pressed():
	GDVK.press("O")


func _on_KeyE_pressed():
	GDVK.key_down("SHIFT")
	GDVK.press("1")
	GDVK.key_up("SHIFT")
	


func _on_KeyH_pressed():
	GDVK.press("H")
	pass # Replace with function body.


func _on_KeyL_pressed():
	GDVK.press("L")
	pass # Replace with function body.


func _on_KeyCaps_pressed():
	GDVK.press("CAPSLOCK")
	pass # Replace with function body.
