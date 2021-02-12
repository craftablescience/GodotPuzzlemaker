# vmflib-godot
A port of vmflib2 to the Godot Game Engine.

## Information

This addon allows you to create a Source Engine VMF file, and export to a BSP.
It is targeted towards Portal 2, although other games will work with it.
This was made for my "Godot Puzzlemaker" level editor, and I will update it as necessary.
It is targeted toward desktop platforms, but should theoretically work on any platform Godot does.

The code is an improved version of [https://github.com/Trainzack/vmflib2](https://github.com/Trainzack/vmflib2), which is under the BSD 2-Clause "Simplified" License.
Thus, this code is as well. See more info at LICENSE.

This addon is still in development. The overall foundation is in place, it is just a matter of adding more entity and texture listings, and adding more features.

## Installation

1. Download this repository as a ZIP.
2. Unzip the downloaded file anywhere.
3. Copy the `addons/` folder to the root folder of your project. It won't overwrite any addons you currently have installed.
4. In Project Settings, under the Plugins tab select the checkbox to enable the `vmflib` plugin.
5. In Project Settings, under the AutoLoad tab add `addons/vmflib/VMFDataManager.gd` as a singleton.
   **Make sure it is exactly called VMFDataManager, Godot may make some letters lowercase.**

## Usage

In the script to create a level, write:

`var vmf = VMF.new(VMF.GAMES.GameToExportToHere)`

This object is how you add brushes, entities, and export to VMF and/or BSP.

To add a brush, you can write something like this.
Note that every Vector3 argument uses a +Y = UP coordinate system, where the exported VMF uses a +Z = UP coordinate system.
This is because of personal preference.

`vmf.add_solid(VMF.Block.new(Vector3(0, 0, 0), Vector3(64, 64, 64), vmf.COMMON_MATERIALS.DEV_MEASUREWALL01A).brush)`

In the Block constructor, the first argument is the coordinates of the center of the block.
The second argument is the size of the block.
The third argument is the texture to use for each block face (defaults to "TOOLS/TOOLSNODRAW").

To change the texture of one face, add `.set_material_face(material: String, face: Vector3)` before `.brush`.
This function modifies the block object it is called on, but it also returns the block object, so it can be chained.
Use `Vector3.UP`, `Vector3.DOWN`, `Vector3.LEFT`, etc. to select the face to change.

Adding an entity is slightly different. Here is an example:

`var info_player_start = VMF.Entities.Common.InfoPlayerStartEntity.new(vmf, Vector3(0, 64, 0))`

Each type of entity is an instance of a separate helper class.
It adds itself to the VMF object passed to the constructor automatically.
Depending on the type of entity, there are different arguments.

Finally, run `vmf.write_vmf(file_path_here: String)` to save the VMF to the specified path, or save the value of `str(vmf)` for use in scripting.
