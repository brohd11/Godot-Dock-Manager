@tool
extends Node

const EditorNodes = preload("editor_nodes.gd") #>import editor_nodes.gd

var editor_plugin:EditorPlugin
var plugin_control:Control
var main_screen_button:Button

func _init(_editor_plugin, _plugin_control) -> void:
	editor_plugin = _editor_plugin
	plugin_control = _plugin_control
	_connect_buttons()
	var bar_children = EditorNodes.MainScreen.get_button_container()
	for child in bar_children.get_children():
		if String(child.name) == editor_plugin._get_plugin_name():
			main_screen_button = child
			main_screen_button.hide()
			break

func clean_up():
	pass

func _connect_buttons():
	var main_bar = EditorNodes.MainScreen.get_button_container()
	for button:Button in main_bar.get_children():
		if not button.pressed.is_connected(_on_main_screen_bar_button_pressed):
			button.pressed.connect(_on_main_screen_bar_button_pressed.bind(button))

func _on_main_screen_bar_button_pressed(button:Button):
	if button == main_screen_button and main_screen_button.button_pressed:
		EditorInterface.set_main_screen_editor.call_deferred(editor_plugin._get_plugin_name())
		plugin_control.show()
	else:
		plugin_control.hide()


func add_main_screen_control(control):
	plugin_control = control
	main_screen_button.show()
	EditorInterface.get_editor_main_screen().add_child(control)
	plugin_control.name = editor_plugin._get_plugin_name()
	plugin_control.hide()

func remove_main_screen_control(control):
	if is_instance_valid(main_screen_button):
		main_screen_button.hide()
	EditorInterface.get_editor_main_screen().remove_child(control)
	EditorInterface.set_main_screen_editor("Script")


func _get_control_icon(control):
	if "_get_plugin_icon" in editor_plugin:
		return editor_plugin._get_plugin_icon()
	elif "icon" in control:
		return control.icon
	else:
		return EditorInterface.get_base_control().get_theme_icon("Node", &"EditorIcons")
	
