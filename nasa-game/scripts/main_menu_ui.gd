extends Control

@export_file("*.tscn") var main_game_scene: String = "res://scenes/main_game.tscn"
@onready var quit_dialog: ConfirmationDialog = $"CenterContainer/VBoxContainer/Quit Button/ConfirmationDialog"
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var volume_slider: HSlider = $SettingsPanel/MarginContainer/VBoxContainer/VolumeSlider
@onready var fullscreen_check: CheckBox = $SettingsPanel/MarginContainer/VBoxContainer/FullscreenCheck
@onready var main_menu: CenterContainer = $CenterContainer
@onready var credits_window: AcceptDialog = $"CenterContainer/VBoxContainer/Credits Button/Window"

func _ready() -> void:
	#get_tree().paused = true
	# kyle the buttons weren't working because the tree was paused
	# if you want the buttons to work while the tree's paused, set the buttons' process_mode variable to 
	# either always or on paused
	main_menu.show()
	quit_dialog.hide()
	settings_panel.hide()
	$AnimatedSprite2D.sprite_frames.set_animation_loop("default", true)
	$AnimatedSprite2D.play("default")
	var master_bus = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_start_button_pressed() -> void:
	var error: Error = get_tree().change_scene_to_file(main_game_scene)
	if error != OK:
		push_error("Could not open the main game scene: %s" % error_string(error))

func _on_settings_button_pressed() -> void:
	main_menu.hide()
	settings_panel.show()

func _on_quit_button_pressed() -> void:
	quit_dialog.popup_centered()

func _on_confirmation_dialog_confirmed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	main_menu.show()
	settings_panel.hide()

func _on_volume_slider_value_changed(value: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value <= 0.01)

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_accessibility_check_toggled(toggled_on: bool) -> void:
	print("Accessibility toggled: ", toggled_on)

func _on_credits_button_pressed() -> void:
	credits_window.popup_centered()
