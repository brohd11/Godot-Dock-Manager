@tool
extends EditorPlugin

# You can place the dock_manager folder anywhere in plugin, then preload here.
# Alternatively, use as a global class and use with Plugin Exporter

var dm_ins_manager:DockManager.InstanceManager

const GUI_SCENE = preload("res://addons/dock_manager/demo_gui.tscn")
const OTHER_GUI = preload("res://addons/dock_manager/demo_other_gui.tscn")
const THIRD_GUI = preload("res://addons/dock_manager/demo_third_gui.tscn")

# must have this function
func _get_plugin_name() -> String:
	return "Test Docking"

# if you want to use main screen, function must be present, along with _make_visible calling the instance manager
func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	dm_ins_manager.on_plugin_make_visible(visible)

# Can be used in single GUI mode. In multi GUI mode, docks will be named as the root of the scene and you can declare
# variable "icon" in your scene script.
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons")

func _enter_tree() -> void:
	var load_freeable_docks = true # loads freeable docks that haven't been manually freed
	var allow_single_instance = true # onlt allow a single instance of a scene to be instanced
	dm_ins_manager = DockManager.InstanceManager.new(self, load_freeable_docks, allow_single_instance)
	
	dm_ins_manager.new_persistent_dock_manager(GUI_SCENE, DockManager.Slot.BOTTOM_PANEL)
	
	add_tool_menu_item("Other GUI", _on_other_gui_tool_menu_pressed)
	add_tool_menu_item("Third GUI", _on_third_gui_tool_menu_pressed)

func _exit_tree() -> void:
	if is_instance_valid(dm_ins_manager):
		dm_ins_manager.clean_up()
	
	remove_tool_menu_item("Other GUI")
	remove_tool_menu_item("Third GUI")

func _get_window_layout(configuration: ConfigFile) -> void:
	dm_ins_manager.save_layout_data() # saves layout everytime it is changed, vs on exit only

func _on_other_gui_tool_menu_pressed():
	dm_ins_manager.new_freeable_dock_manager(OTHER_GUI, DockManager.Slot.BOTTOM_PANEL)

func _on_third_gui_tool_menu_pressed():
	dm_ins_manager.new_freeable_dock_manager(THIRD_GUI, DockManager.Slot.BOTTOM_PANEL)
