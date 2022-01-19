extends Control

const OVERLAY_PROPERTIES = {
	"has_touch": true,
}

func _ready():
	pass


func _on_KeyO_pressed():
	GDVK.press("O")


func _on_KeyE_pressed():
	GDVK.press("E")
	pass # Replace with function body.


func _on_KeyH_pressed():
	GDVK.press("H")
	pass # Replace with function body.


func _on_KeyL_pressed():
	GDVK.press("L")
	pass # Replace with function body.


func _on_KeyCaps_pressed():
	GDVK.press("CAPSLOCK")
	pass # Replace with function body.
