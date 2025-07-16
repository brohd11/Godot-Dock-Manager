# Dock Manager class for Godot Plugins

This is a class you can use when creating plugins. It allows you to swap your plugin GUI between Docks, Bottom Panel, or Main Screen. It supports multiple GUIs per plugin.

https://github.com/user-attachments/assets/60eb7fd6-dd16-4a2e-ba91-3a1e958fc387

Below is a simple implementation of the class. The demo has an example using 3 GUIs, 2 of which can be free-ed, good for times where the tool is not used that often.

Drag "dock_manager" folder anywhere into your plugin, then preload "dock_manager.gd" in your EditorPlugin script.

Add a button to your GUI scene, and declare it as "@onready var dock_button = %DockButton". The "MakeFloating" icon will be added by the dock manager, so no need to assign it.

Now you can just create an instance of the DockManager class and pass your scene through. See the demo plugin for multi GUI example.

Known Bug: If you disable the plugin while on a main screen that you have added with multiple GUIs, the plugin will fail to remove the button and you will need to restart the editor. Click onto a different main screen before disabling.

```gdscript
const DockManager = preload("uid://cwjfdybghwcm") # dock_manager.gd
var dock_manager:DockManager

const GUI_SCENE = preload("uid://codfq5nb74vn7") # demo_control.tscn

func _get_plugin_name() -> String:
	return "My Plugin"

func _has_main_screen() -> bool:
	return true


func _enter_tree() -> void:
	dock_manager = DockManager.new(self, GUI_SCENE, DockManager.Slot.BOTTOM_PANEL)

func _exit_tree() -> void:
	dock_manager.clean_up() # frees GUI, saves layout

func _get_window_layout(configuration: ConfigFile) -> void:
	dock_manager.save_layout_data() # saves layout everytime it is changed, vs on exit
```
