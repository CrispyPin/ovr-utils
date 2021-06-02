extends Control


var types: Array

func _ready() -> void:
	visible = false
	types = get_overlay_types()
	for t in types:
		var btn = preload("res://ui/AddOverlayButton.tscn").instance()
		btn.text = t
		btn.connect("pressed", self, "add_overlay", [t])
		$MarginContainer/VBoxContainer.add_child(btn)


func add_overlay(type):
	OverlayManager.add_overlay(type, type + str(randi()%100))
	visible = false


func get_overlay_types(path := "res://overlays/"):
	var found = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# TODO make recursive, must include folder as prefix for type
				pass
			else:
				found.append(file_name.split(".")[0])
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path ", path)
	return found
