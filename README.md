# Dock Manager class for Godot Plugins

This is a class you can use when creating plugins. It allows you to swap your plugin GUI between Docks, Bottom Panel, or Main Screen. It supports multiple GUIs per plugin.

https://github.com/user-attachments/assets/60eb7fd6-dd16-4a2e-ba91-3a1e958fc387

Drag "dock_manager" folder anywhere into your plugin, then preload "dock_manager.gd" in your EditorPlugin script.

Add a button to your GUI scene, and declare it as "@onready var dock_button = %DockButton". The "MakeFloating" icon will be added by the dock manager, so no need to assign it.

Now you can just create an instance of the DockManager class and pass your scene through.

Known Bug: If you disable the plugin while on a main screen that you have added with multiple GUIs, the plugin will fail to remove the button and you will need to restart the editor. Click onto a different main screen before disabling.

```gdscript
const DockManager = preload("uid://bpxufoy7tnkfk") # dock_manager.gd
var dock_manager:DockManager

const GUI_SCENE = preload("res://addons/my_plugin/gui.tscn")

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

## Multiple GUIs

`InstanceManager` handles more than one GUI per plugin. Freeable docks are torn down when closed and
restored from the saved layout on load, which suits tools that are not open often.

```gdscript
var dm_instance_manager:DockManager.InstanceManager

func _enter_tree() -> void:
	dm_instance_manager = DockManager.InstanceManager.new(self, true)
	dm_instance_manager.new_persistent_dock_manager(MAIN_GUI, DockManager.Slot.BOTTOM_PANEL)

func _open_extra_panel() -> void:
	dm_instance_manager.new_freeable_dock_manager(OTHER_GUI, DockManager.Slot.FLOATING)

func _exit_tree() -> void:
	dm_instance_manager.clean_up()
```
