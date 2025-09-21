@tool
extends EditorPlugin

# you can place the dock_manager folder anywhere in plugin, then preload here

var dock_manager:DockManager
var dock_manager2:DockManager
var dock_manager3:DockManager

var main_screen_handler: DockManager.MainScreenHandlerMulti

const GUI_SCENE = preload("res://addons/dock_manager/demo_gui.tscn")
const OTHER_GUI = preload("res://addons/dock_manager/demo_other_gui.tscn")
const THIRD_GUI = preload("res://addons/dock_manager/demo_third_gui.tscn")

# must have
func _get_plugin_name() -> String:
	return "Test Docking"

# must have
func _has_main_screen() -> bool:
	return true

# Can be used in single GUI mode. In multi GUI mode, docks will be named as the root of the scene and you can declare
# variable "icon" in your scene script. See: "demo_gui.gd". _DockManager.new(self, gui, Slot, false), 4th argument sets GUI mode.
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons")


func _enter_tree() -> void:
	main_screen_handler = DockManager.MainScreenHandlerMulti.new(self)
	
	var can_be_freed = false
	dock_manager = DockManager.new(self, GUI_SCENE, dock_manager.Slot.BOTTOM_PANEL, can_be_freed, main_screen_handler)
	# class needs reference to plugin and GUI, other params optional.
	
	add_tool_menu_item("Other GUI", _on_other_gui_tool_menu_pressed)
	add_tool_menu_item("Third GUI", _on_third_gui_tool_menu_pressed)

func _exit_tree() -> void:
	dock_manager.clean_up() # frees GUI, saves layout
	if is_instance_valid(dock_manager2):
		dock_manager2.clean_up()
	if is_instance_valid(dock_manager3):
		dock_manager3.clean_up()
	if is_instance_valid(main_screen_handler):
		main_screen_handler.clean_up()
		main_screen_handler.queue_free()
	
	remove_tool_menu_item("Other GUI")
	remove_tool_menu_item("Third GUI")

func _get_window_layout(configuration: ConfigFile) -> void:
	dock_manager.save_layout_data() # saves layout everytime it is changed, vs on exit only
	if is_instance_valid(dock_manager2):
		dock_manager2.save_layout_data()
	if is_instance_valid(dock_manager3):
		dock_manager3.save_layout_data()

func _on_other_gui_tool_menu_pressed():
	if is_instance_valid(dock_manager2):
		print("ALREADY INSTANCED: ", dock_manager2.plugin_control)
		return
	var can_be_freed = true
	dock_manager2 = DockManager.new(self, OTHER_GUI, DockManager.Slot.BOTTOM_PANEL, can_be_freed, main_screen_handler)

func _on_third_gui_tool_menu_pressed():
	if is_instance_valid(dock_manager3):
		print("ALREADY INSTANCED: ", dock_manager3.plugin_control)
		return
	var can_be_freed = true
	dock_manager3 = DockManager.new(self, THIRD_GUI, DockManager.Slot.BOTTOM_PANEL, can_be_freed, main_screen_handler)
