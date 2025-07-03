@tool
extends Control

@onready var dock_button: Button = %DockButton

var icon:Texture2D

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("Debug", &"EditorIcons")
