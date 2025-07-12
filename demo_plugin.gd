@tool
extends EditorPlugin

# you can place the dock_manager folder anywhere in plugin, then preload here
const _DockManagerClass = preload("res://addons/dock_manager/src/dock_manager/dock_manager.gd") # dock_manager.gd
var DockManager:_DockManagerClass
var DockManager2:_DockManagerClass

const GUI_SCENE = preload("res://addons/dock_manager/demo_gui.tscn") # demo_control.tscn
#var gui_instance

const OTHER_GUI = preload("res://addons/dock_manager/demo_other_gui.tscn") # demo_other_gui.tscn

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
	#gui_instance = GUI_SCENE.instantiate()
	var multi_gui = true
	var can_be_freed = false
	DockManager = _DockManagerClass.new(self, GUI_SCENE, DockManager.Slot.BOTTOM_PANEL, can_be_freed, multi_gui)
	# class needs reference to plugin and GUI, other params optional.
	
	add_tool_menu_item("Other GUI", _on_other_gui_tool_menu_pressed)

func _exit_tree() -> void:
	DockManager.clean_up() # frees GUI, saves layout
	if is_instance_valid(DockManager2):
		DockManager2.clean_up()
	
	remove_tool_menu_item("Other GUI")

func _get_window_layout(configuration: ConfigFile) -> void:
	DockManager.save_layout_data() # saves layout everytime it is changed, vs on exit only
	
	if is_instance_valid(DockManager2):
		DockManager2.save_layout_data()

func _on_other_gui_tool_menu_pressed():
	if is_instance_valid(DockManager2):
		print("ALREADY INSTANCED: ", DockManager2)
		return
	
	var multi_gui = true
	var can_be_freed = true
	DockManager2 = _DockManagerClass.new(self, OTHER_GUI, DockManager.Slot.BOTTOM_PANEL, can_be_freed, multi_gui)
