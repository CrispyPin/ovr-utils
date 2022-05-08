# WIP documentation

## Hierarchy

```
OverlayManager
- MyOverlayInstance
  - [...]
  - OverlayViewport
    - Container
	  - MyOverlay
	- [...]
  - OverlayInteraction
    - VR
		- [colliders for vr trackers etc]
	- Grabbable
	- Clickable
	- Touchable

```


## overlay interaction types
Each overlay instance has a OverlayInteraction node, which spawns the different interaction modules depending on what is defined in the OVERLAY_PROPERTIES.

The modules/interaction types are:
- Grabbable
- Touchable
- Clickable

These modules connect signals from different places to the interaction manager (`OverlayInteraction`)
Touchable connects collision signals to mouse inputs (potentially logic between to help prevent double presses)
Clickable connects vr button signals to mouse inputs
Grabbable connects vr button signals to grab logic, while telling the interaction manager to pause normal interaction

