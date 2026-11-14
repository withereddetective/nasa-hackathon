extends Control

@export_file("main_game.tscn") var main_game_scene: String
@onready var quit_dialog: ConfirmationDialog = $"CenterContainer/VBoxContainer/Quit Button/ConfirmationDialog"

func _ready() -> void:
	#get_tree().paused = true
	# kyle the buttons weren't working because the tree was paused
	# if you want the buttons to work while the tree's paused, set the buttons' process_mode variable to 
	# either always or on paused
	quit_dialog.hide()
	$AnimatedSprite2D.sprite_frames.set_animation_loop("default", true)
	$AnimatedSprite2D.play("default")

func _on_start_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_settings_button_pressed() -> void:
	print("Open settings panel")

func _on_quit_button_pressed() -> void:
	quit_dialog.popup_centered()

func _on_confirmation_dialog_confirmed() -> void:
	get_tree().quit()
