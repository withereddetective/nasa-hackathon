extends Node2D

@onready var main_menu_ui: Control = $"Main Menu UI"

func _ready() -> void:
	get_tree().paused = true
	main_menu_ui.show()
