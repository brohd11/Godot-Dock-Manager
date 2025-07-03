@tool
extends EditorPlugin

# you can place the dock_manager folder anywhere in plugin, then preload here
const _DockManagerClass = preload("uid://cwjfdybghwcm") # dock_manager.gd
var DockManager:_DockManagerClass
var DockManager2:_DockManagerClass

const GUI_SCENE = preload("uid://codfq5nb74vn7") # demo_control.tscn
var gui_instance

const OTHER_GUI = preload("uid://bxmwwhywlfq5x") # demo_other_gui.tscn
var other_gui

# must have
func _get_plugin_name() -> String:
	return "Test Docking"

# must have
func _has_main_screen() -> bool:
	return true

# Can be used in single GUI mode. In multi GUI mode, docks will be named as the root of the scene and you can declare
# variable "icon" in your scene script. See: "demo_gui.gd". _DockManagerClass.new(self, gui, Slot, false), 4th argument sets GUI mode.
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons")


func _enter_tree() -> void:
	gui_instance = GUI_SCENE.instantiate() # class needs reference to plugin and GUI, other params optional.
	DockManager = _DockManagerClass.new(self, gui_instance)
	
	other_gui = OTHER_GUI.instantiate()
	DockManager2 = _DockManagerClass.new(self, other_gui, DockManager.Slot.BOTTOM_PANEL)

func _exit_tree() -> void:
	DockManager.clean_up() # frees GUI, saves layout
	DockManager2.clean_up()

func _get_window_layout(configuration: ConfigFile) -> void:
	DockManager.save_layout_data() # saves layout everytime it is changed, vs on exit only
	DockManager2.save_layout_data()
