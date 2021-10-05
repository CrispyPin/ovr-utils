extends Control

signal add_menu_closed

var paths: Array

func _ready() -> void:
	visible = false
	paths = get_overlay_paths()
	for p in paths:
		var btn = preload("res://ui/AddOverlayButton.tscn").instance()
		btn.text = path_to_name(p)
		btn.connect("pressed", self, "add_overlay", [p])
		$MarginContainer/VBoxContainer.add_child(btn)


func add_overlay(path):
	OverlayManager.create_overlay(path, path_to_name(path) + " " + str(randi()%1000))
	visible = false
	emit_signal("add_menu_closed")


func get_overlay_paths(root := "res://overlays/"):
	var found = []
	var dir = Directory.new()
	if dir.open(root) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# TODO make recursive
				pass
			else:
				found.append(root + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access ", root)
	return found

func path_to_name(path: String) -> String:
	return path.split("/")[-1].split(".")[0]
