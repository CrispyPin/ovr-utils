# OVR Utils
A cross-platform SteamVR overlay application that aims to have many useful tools available while in VR. Built using the Godot game engine, and the godot-openvr plugin to interact with the openvr SDK.

## Installation
* Grab the latest release for your OS from the [releases section](https://github.com/CrispyPin/ovr-utils/releases)
* Extract the contents to somewhere (make sure to mark `ovr-utils-linux-v###.x86_64` as executable on linux)
* To start the overlay, just run the `.exe` or `.x86_64` file.
### Add to steam (optional)
* In steam, go to `Games`>`Add a non-steam game to my library`
* Click browse and find the `ovr-utils` executable
* Click `add` and then `add selected programs`
* You should now be able to start it from steam (favourite it for easier access)

## Usage
At the moment all interacions are done with the trigger buttons, this will use steamvr actions and be configurable in the future.

To load in images with the `ImageViewer` overlay, they have to be in the user folder; that is `%Appdata%\Roaming\ovr-utils\` on windows or `~/.local/share/ovr-utils/` on linux.
