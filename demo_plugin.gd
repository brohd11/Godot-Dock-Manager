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

func _get_plugin_name() -> String:
	return "Test Docking"

func _has_main_screen() -> bool:
	return true

func _get_plugin_icon() -> Texture2D: # _DockManagerClass.new(self, gui, default_dock, false) 4th argument forces GUI name to plugin name 
	return EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons") # and icon, simplified for logic single GUIs


func _enter_tree() -> void:
	gui_instance = GUI_SCENE.instantiate()
	DockManager = _DockManagerClass.new(self, gui_instance, DockManager.Slot.BOTTOM_PANEL)
	
	other_gui = OTHER_GUI.instantiate()
	DockManager2 = _DockManagerClass.new(self, other_gui, DockManager.Slot.DOCK_SLOT_LEFT_UR)

func _exit_tree() -> void:
	DockManager.clean_up() # frees GUI, saves layout
	DockManager2.clean_up()

func _get_window_layout(configuration: ConfigFile) -> void:
	DockManager.save_layout_data() # saves layout everytime it is changed, vs on exit
	DockManager2.save_layout_data()
