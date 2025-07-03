@tool
extends RefCounted

static func get_current_dock(control):
	var parent = control.get_parent()
	if not parent:
		#print("Parent is null. Get dock.")
		return
	if parent == Docks.get_left_ul():
		return EditorPlugin.DockSlot.DOCK_SLOT_LEFT_UL
	elif parent == Docks.get_left_bl():
		return EditorPlugin.DockSlot.DOCK_SLOT_LEFT_BL
	elif parent == Docks.get_left_ur():
		return EditorPlugin.DockSlot.DOCK_SLOT_LEFT_UR
	elif parent == Docks.get_left_br():
		return EditorPlugin.DockSlot.DOCK_SLOT_LEFT_BR
	elif parent == Docks.get_right_ul():
		return EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UL
	elif parent == Docks.get_right_bl():
		return EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_BL
	elif parent == Docks.get_right_ur():
		return EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UR
	elif parent == Docks.get_right_br():
		return EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_BR
	elif parent == BottomPanel.get_bottom_panel():
		return -2
	elif parent == MainScreen.get_main_screen():
		return -1
	else:
		return -3

static func get_current_dock_control(control):
	var parent = control.get_parent()
	if not parent:
		#print("Parent is null. Get control.")
		return
	if parent is TabContainer:
		return parent
	elif parent == BottomPanel.get_bottom_panel():
		return parent
	elif parent == MainScreen.get_main_screen():
		return parent


class Docks:
	static func get_left_h_split():
		var split = EditorInterface.get_base_control().get_child(0).get_child(1)
		return split
	static func get_left_ul() -> TabContainer:
		var split = get_left_h_split()
		var tab = split.get_child(0).get_child(0)
		return tab
	static func get_left_bl():
		var split = get_left_h_split()
		var tab = split.get_child(0).get_child(1)
		return tab
	static func get_left_ur():
		var split = get_left_h_split()
		var tab = split.get_child(1).get_child(0).get_child(0)
		return tab
	static func get_left_br():
		var split = get_left_h_split()
		var tab = split.get_child(1).get_child(0).get_child(1)
		return tab
	static func get_right_h_split():
		var left_split = get_left_h_split()
		var split = left_split.get_child(1).get_child(1).get_child(1)
		return split
	static func get_right_ul():
		var split = get_right_h_split()
		var tab = split.get_child(0).get_child(0)
		return tab
	static func get_right_bl():
		var split = get_right_h_split()
		var tab = split.get_child(0).get_child(1)
		return tab
	static func get_right_ur():
		var split = get_right_h_split()
		var tab = split.get_child(1).get_child(0)
		return tab
	static func get_right_br():
		var split = get_right_h_split()
		var tab = split.get_child(1).get_child(1)
		return tab

class MainScreen:
	static func get_main_screen():
		return EditorInterface.get_editor_main_screen()
	static func get_title_bar():
		return EditorInterface.get_base_control().get_child(0).get_child(0)
	static func get_button_container():
		return get_title_bar().get_child(2)
	static func get_button_theme():
		var button = get_button_container().get_child(0) as Button
		return button.theme_type_variation

class BottomPanel:
	static func get_bottom_panel() -> Control:
		var base = EditorInterface.get_base_control()
		var bp = base.get_child(0).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(1)
		var vbox = bp.get_child(0)
		return vbox
