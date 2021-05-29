extends Node

const DEF = {
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
				"type": {
					"name": "Overlay type",
					"type": "string",
					"default": "UI_demo"
				},
				"width": {
					"name": "Width (m)",
					"type": "number",
					"default": 0.4
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
			"main": {
				"type": "MainOverlay",
				"width": 0.4,
				"target": "left",
				"fallback": ["left", "right", "head"],
				"offsets": {
					"left": {
						"pos": Vector3(),
						"rot": Quat(),
					},
					"right": {
						"pos": Vector3(),
						"rot": Quat(),
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
