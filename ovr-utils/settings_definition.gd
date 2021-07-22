extends Node

const VERSION = 1

const PATH = "user://overlay_data.json"
const DEF = {
	"version": {
		"name": "Version of save file",
		"type": "int",
		"default": VERSION
	},
	"grab_mode": {
		"name": "Grab mode",
		"description": "Grab and drag around any overlay",
		"flags": ["no_save"],
		"type": "bool",
		"default": false
	},
	"overlays": {
		"name": "Settings for all overlays",
		"type": "dict",
		"flags": ["resize"],
		"definition": {
			"type": "dict",
			"definition": {
				"path": {
					"name": "Overlay scene path",
					"type": "string",
					"default": "res://special_overlays/UnknownType.tscn"
				},
				"visible": {
					"name": "Overlay Visible",
					"type": "bool",
					"default": true
				},
				"width": {
					"name": "Width (m)",
					"type": "float",
					"default": 0.4
				},
				"alpha": {
					"name": "Alpha",
					"type": "float",
					"default": 1.0
				},
				"target": {
					"name": "Tracking target",
					"type": "string",
					"default": "world"
				},
				"fallback": {
					"name": "Target fallback priority order",
					"type": "array",
					"default": ["world"]
				},
				"offsets": {
					"name": "Offsets",
					"flags": ["resize"],
					"type": "dict",
					"definition": {
						"type": "dict",
						"definition":{
							"pos": {
								"name": "Offset position",
								"type": "vector3",
								"default": Vector3()
							},
							"rot": {
								"name": "Offset rotation",
								"type": "quat",
								"default": Quat()
							}
						}
					},
					"default": {}
				}
			}
		},
		"default": {
			"MainOverlay": {
				"path": "res://special_overlays/MainOverlay.tscn",
				"visible": true,
				"width": 0.4,
				"alpha": 1.0,
				"target": "left",
				"fallback": ["left", "right", "head"],
				"offsets": {
					"left": {
						"pos": Vector3(0.15, 0.05, 0),
						"rot": Quat(-0.653928, -0.023545, 0.008617, 0.756141),
					},
					"right": {
						"pos": Vector3(-0.15, 0.05, 0),
						"rot": Quat(-0.653928, -0.023545, 0.008617, 0.756141),
					},
					"head": {
						"pos": Vector3(0,0,-0.5),
						"rot": Quat(),
					},
				}
			}
		}
	}
}
