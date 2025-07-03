@tool
extends Button

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	icon = EditorInterface.get_base_control().get_theme_icon("MakeFloating", &"EditorIcons")
