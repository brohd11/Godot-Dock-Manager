# Dock Manager class for Godot Plugins

This is a class you can use when creating plugins. It allows you to swap your plugin GUI between Docks, Bottom Panel, or Main Screen. It supports multiple GUIs per plugin.

https://github.com/user-attachments/assets/60eb7fd6-dd16-4a2e-ba91-3a1e958fc387

Drag "dock_manager" folder anywhere into your plugin, then preload "dock_manager.gd" in your EditorPlugin script.

Add "dock_button.tscn" to your GUI scene, and declare it as "@onready var dock_button = %DockButton".

Now you can just create an instance of the DockManager class and pass your scene through. See the demo plugin for multi GUI example.
```
const _DockManagerClass = preload("uid://cwjfdybghwcm") # dock_manager.gd
var DockManager:_DockManagerClass

const GUI_SCENE = preload("uid://codfq5nb74vn7") # demo_control.tscn
var gui_instance

func _get_plugin_name() -> String:
	return "My Plugin"

func _has_main_screen() -> bool:
	return true

func _enter_tree() -> void:
	gui_instance = GUI_SCENE.instantiate()
	DockManager = _DockManagerClass.new(self, gui_instance, DockManager.Slot.BOTTOM_PANEL)

func _exit_tree() -> void:
	DockManager.clean_up() # frees GUI, saves layout

func _get_window_layout(configuration: ConfigFile) -> void:
	DockManager.save_layout_data() # saves layout everytime it is changed, vs on exit
```
