@tool
extends RefCounted

const EditorNodes = preload("class/editor_nodes.gd") #>import editor_nodes.gd
const DockPopupHandler = preload("remote/dock_popup_handler.gd") #>remote
const _MainScreenHandlerClass = preload("class/main_screen_handler.gd")
const _MainScreenHandlerMultiClass = preload("class/main_screen_handler_multi.gd")

var MainScreenHandler #>class_inst

var plugin:EditorPlugin
var plugin_control:Control
var dock_button:Button
var default_dock:int
var multi_gui:bool

enum Slot{
	FLOATING,
	BOTTOM_PANEL,
	MAIN_SCREEN,
	DOCK_SLOT_LEFT_UL,
	DOCK_SLOT_LEFT_BL,
	DOCK_SLOT_LEFT_UR,
	DOCK_SLOT_LEFT_BR,
	DOCK_SLOT_RIGHT_UL,
	DOCK_SLOT_RIGHT_BL,
	DOCK_SLOT_RIGHT_UR,
	DOCK_SLOT_RIGHT_BR,
}
const _slot = {
	Slot.FLOATING: -3,
	Slot.BOTTOM_PANEL: -2,
	Slot.MAIN_SCREEN: -1,
	Slot.DOCK_SLOT_LEFT_UL: EditorPlugin.DockSlot.DOCK_SLOT_LEFT_UL,
	Slot.DOCK_SLOT_LEFT_BL: EditorPlugin.DockSlot.DOCK_SLOT_LEFT_BL,
	Slot.DOCK_SLOT_LEFT_UR: EditorPlugin.DockSlot.DOCK_SLOT_LEFT_UR,
	Slot.DOCK_SLOT_LEFT_BR: EditorPlugin.DockSlot.DOCK_SLOT_LEFT_BR,
	Slot.DOCK_SLOT_RIGHT_UL: EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UL,
	Slot.DOCK_SLOT_RIGHT_BL: EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_BL,
	Slot.DOCK_SLOT_RIGHT_UR: EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UR,
	Slot.DOCK_SLOT_RIGHT_BR: EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_BR,
}

func _init(_plugin:EditorPlugin, _plugin_control:Control, _default_dock:Slot=Slot.BOTTOM_PANEL, _multi_gui:=true) -> void:
	plugin = _plugin
	plugin_control = _plugin_control
	default_dock = _slot.get(_default_dock)
	multi_gui = _multi_gui
	_init_async()

func _init_async():
	plugin.add_child(plugin_control)
	await plugin.get_tree().process_frame
	plugin.remove_child(plugin_control)
	
	if "dock_button" in plugin_control:
		dock_button = plugin_control.dock_button
		dock_button.pressed.connect(_on_dock_button_pressed)
	else:
		print("Need dock button in scene to use Dock Manager.")
	if multi_gui:
		MainScreenHandler = _MainScreenHandlerMultiClass.new(plugin, plugin_control)
	else:
		plugin_control.name = plugin._get_plugin_name()
		MainScreenHandler = _MainScreenHandlerClass.new(plugin, plugin_control)
	plugin.add_child(MainScreenHandler)
	
	var layout_data = load_layout_data()
	var dock_target = layout_data.get("current_dock", default_dock)
	if dock_target == null:
		dock_target = default_dock
	if dock_target > -3:
		dock_instance(int(dock_target))
	else:
		undock_instance()

func clean_up():
	save_layout_data()
	_remove_control_from_parent()
	plugin_control.queue_free()
	MainScreenHandler.clean_up()
	MainScreenHandler.queue_free()

func load_layout_data():
	if not FileAccess.file_exists(_get_layout_file_path()):
		return {}
	var data = read_from_json(_get_layout_file_path())
	var scene_data = data.get(plugin_control.scene_file_path, {})
	return scene_data

func save_layout_data():
	var current_dock = EditorNodes.Docks.get_current_dock(plugin_control)
	if current_dock == -3:
		return
	var data = {}
	if FileAccess.file_exists(_get_layout_file_path()):
		data = read_from_json(_get_layout_file_path())
	var scene_data = {"current_dock": current_dock}
	data[plugin_control.scene_file_path] = scene_data
	
	write_to_json(data, _get_layout_file_path())

func _get_layout_file_path():
	var script = self.get_script() as Script
	var path = script.resource_path
	var dir = path.get_base_dir()
	var layout_path = dir.path_join("config/layout.json")
	return layout_path

func _on_dock_button_pressed():
	var dock_popup_handler = DockPopupHandler.new(plugin_control)
	var handled = await dock_popup_handler.handled
	if handled is String:
		return
	
	var current_dock = EditorNodes.Docks.get_current_dock(plugin_control)
	if current_dock == handled:
		return
	
	if handled == -3:
		undock_instance()
	else:
		dock_instance(handled)

func dock_instance(target_dock:int):
	var window = plugin_control.get_window()
	_remove_control_from_parent()
	if target_dock > -1:
		plugin.add_control_to_dock(target_dock, plugin_control)
	elif target_dock == -1:
		MainScreenHandler.add_main_screen_control(plugin_control)
	elif target_dock == -2:
		var name = plugin_control.name
		plugin.add_control_to_bottom_panel(plugin_control, name)
	
	if is_instance_valid(window):
		if window is PanelWindow:
			window.queue_free()

func undock_instance():
	_remove_control_from_parent()
	var window = PanelWindow.new(plugin_control)
	window.close_requested.connect(window_close_requested)
	#window.mouse_entered.connect(_on_window_mouse_entered.bind(window))
	#window.mouse_exited.connect(_on_window_mouse_exited)
	
	return window

func _remove_control_from_parent():
	var current_dock = EditorNodes.Docks.get_current_dock(plugin_control)
	var control_parent = plugin_control.get_parent()
	if is_instance_valid(control_parent):
		if current_dock > -1:
			plugin.remove_control_from_docks(plugin_control)
		elif current_dock == -1:
			MainScreenHandler.remove_main_screen_control(plugin_control)
		elif current_dock == -2:
			plugin.remove_control_from_bottom_panel(plugin_control)
		else:
			control_parent.remove_child(plugin_control)


func window_close_requested() -> void:
	var layout_data = load_layout_data()
	var current_dock = layout_data.get("current_dock", default_dock)
	dock_instance(current_dock)
func _on_window_mouse_entered(window):
	window.grab_focus()
func _on_window_mouse_exited():
	EditorInterface.get_base_control().get_window().grab_focus()


class PanelWindow extends Window: #>class
	func _init(control) -> void:
		initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
		size = Vector2i(1200,800)
		EditorInterface.get_base_control().add_child(self)
		var panel = PanelContainer.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(panel)
		always_on_top = true
		
		if is_instance_valid(control.get_parent()):
			control.reparent(panel)
		else:
			panel.add_child(control)
		
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		control.show()


static func write_to_json(data:Variant,path:String,access=FileAccess.WRITE_READ) -> void:
	var data_string = JSON.stringify(data,"\t")
	var json_file = FileAccess.open(path, access)
	json_file.store_string(data_string)

static func read_from_json(path:String,access=FileAccess.READ) -> Dictionary:
	var json_read = JSON.new()
	var json_load = FileAccess.open(path, access)
	if json_load == null:
		print("Couldn't load JSON: ", path)
		return {}
	var json_string = json_load.get_as_text()
	var err = json_read.parse(json_string)
	if err != OK:
		print("Couldn't load JSON, error: ", err)
		return {}
	
	return json_read.data
