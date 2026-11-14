extends Control

const TEXT: Color = Color("#edf4fb")
const MUTED: Color = Color("#9aadc2")
const ACCENT: Color = Color("#72e0ad")
const GOLD: Color = Color("#f4c76b")
const DETAIL_TEXT: Color = Color("#15202b")
const DETAIL_MUTED: Color = Color("#34414c")
const GameData = preload("res://scripts/game_data.gd")
const LaunchSequence = preload("res://scripts/launch_sequence.gd")

var budget: int = GameData.STARTING_BUDGET
var science: int = 0
var completed_missions: Array[String] = []
var selected_mission_index: int = 0

var budget_value: Label
var science_value: Label
var mission_phase_label: Label
var mission_list: VBoxContainer
var mission_scroll: ScrollContainer
var mission_summary: VBoxContainer
var detail_scroll: ScrollContainer
var detail_column: VBoxContainer
var launch_vehicle_picker: OptionButton
var instrument_picker: OptionButton
var launch_button: Button
var launch_status: Label
var quit_dialog: ConfirmationDialog
var settings_button: Button
var settings_panel: VBoxContainer
var settings_volume_slider: HSlider
var settings_fullscreen_check: CheckBox
var settings_reduce_shake_check: CheckBox
var action_bar: HBoxContainer
var reduce_shake: bool = false
var settings_open: bool = false
var monitor_ui_nodes: Array[Control] = []
var monitor_flicker_timer: float = 4.0
var monitor_flicker_frames: int = 0
var monitor_ui_flickering: bool = false
var launch_sequence: LaunchSequence
var pending_mission_index: int = -1
var pending_mission_reward: int = 0
var pending_mission_science: int = 0

@onready var game_background: Sprite2D = $Sprite2D


func _ready() -> void:
	randomize()
	_build_interface()
	launch_sequence = LaunchSequence.new()
	add_child(launch_sequence)
	launch_sequence.award_mission.connect(_complete_launch)
	launch_sequence.finished.connect(_return_to_mission_screen)
	_refresh_interface()


func _process(delta: float) -> void:
	if launch_sequence.is_running():
		return
	_update_monitor_flicker(delta)


func _build_interface() -> void:
	custom_minimum_size = Vector2(GameData.VIEWPORT_WIDTH, GameData.VIEWPORT_HEIGHT)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var title := _make_label("ORBITAL PROGRAM", 18, TEXT)
	title.position = Vector2(110, 10)
	title.size = Vector2(300, 26)
	add_child(title)
	_track_monitor_ui(title)

	var subtitle := _make_label("MISSION CONTROL  /  EARTH ORBIT", 10, MUTED)
	subtitle.position = Vector2(110, 37)
	subtitle.size = Vector2(310, 18)
	add_child(subtitle)
	_track_monitor_ui(subtitle)

	var budget_stat := _build_stat("PROGRAM BUDGET", "$0", ACCENT)
	budget_stat.position = Vector2(525, 16)
	budget_stat.size = Vector2(120, 45)
	add_child(budget_stat)
	_track_monitor_ui(budget_stat)

	var science_stat := _build_stat("SCIENCE", "0 pts", GOLD)
	science_stat.position = Vector2(670, 16)
	science_stat.size = Vector2(100, 45)
	add_child(science_stat)
	_track_monitor_ui(science_stat)

	mission_phase_label = _make_label("", 10, TEXT)
	mission_phase_label.position = Vector2(110, 72)
	mission_phase_label.size = Vector2(235, 20)
	add_child(mission_phase_label)
	_track_monitor_ui(mission_phase_label)

	mission_scroll = ScrollContainer.new()
	mission_scroll.position = Vector2(108, 96)
	mission_scroll.size = Vector2(238, 325)
	mission_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mission_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(mission_scroll)
	_track_monitor_ui(mission_scroll)

	mission_list = VBoxContainer.new()
	mission_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_list.add_theme_constant_override("separation", 4)
	mission_scroll.add_child(mission_list)

	mission_summary = VBoxContainer.new()
	mission_summary.position = Vector2(380, 72)
	mission_summary.size = Vector2(420, 150)
	mission_summary.add_theme_constant_override("separation", 4)
	add_child(mission_summary)
	_track_monitor_ui(mission_summary)

	detail_scroll = ScrollContainer.new()
	detail_scroll.position = Vector2(380, 258)
	detail_scroll.size = Vector2(420, 166)
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	add_child(detail_scroll)
	_track_monitor_ui(detail_scroll)
	detail_column = VBoxContainer.new()
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 4)
	detail_scroll.add_child(detail_column)

	action_bar = HBoxContainer.new()
	action_bar.position = Vector2(110, 482)
	action_bar.size = Vector2(700, 42)
	action_bar.add_theme_constant_override("separation", 12)
	add_child(action_bar)
	var action_spacer := Control.new()
	action_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_bar.add_child(action_spacer)

	settings_button = _make_button("SETTINGS", false)
	settings_button.custom_minimum_size = Vector2(130, 36)
	settings_button.pressed.connect(_show_settings)
	action_bar.add_child(settings_button)
	var quit_button := _make_button("QUIT GAME", false)
	quit_button.custom_minimum_size = Vector2(130, 36)
	quit_button.pressed.connect(_show_quit_dialog)
	action_bar.add_child(quit_button)

	_build_settings_panel()
	_build_quit_dialog()


func _build_quit_dialog() -> void:
	quit_dialog = ConfirmationDialog.new()
	quit_dialog.title = "Quit Game?"
	quit_dialog.dialog_text = "Are you sure you want to quit the game?"
	quit_dialog.ok_button_text = "Quit Game"
	quit_dialog.cancel_button_text = "Keep Playing"
	quit_dialog.confirmed.connect(_quit_game)
	add_child(quit_dialog)


func _build_settings_panel() -> void:
	settings_panel = VBoxContainer.new()
	settings_panel.position = Vector2(386, 266)
	settings_panel.size = Vector2(405, 150)
	settings_panel.add_theme_constant_override("separation", 1)
	settings_panel.visible = false
	add_child(settings_panel)

	var title := _make_label("SETTINGS", 14, Color("#15202b"))
	settings_panel.add_child(title)

	var volume_label := _make_label("MASTER VOLUME", 10, Color("#34414c"))
	settings_panel.add_child(volume_label)
	settings_volume_slider = HSlider.new()
	settings_volume_slider.min_value = 0.0
	settings_volume_slider.max_value = 1.0
	settings_volume_slider.step = 0.05
	settings_volume_slider.custom_minimum_size.y = 22
	var master_bus := AudioServer.get_bus_index("Master")
	settings_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	settings_volume_slider.value_changed.connect(_on_settings_volume_changed)
	settings_panel.add_child(settings_volume_slider)

	settings_fullscreen_check = CheckBox.new()
	settings_fullscreen_check.text = "Fullscreen"
	settings_fullscreen_check.add_theme_color_override("font_color", Color("#15202b"))
	settings_fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	settings_fullscreen_check.toggled.connect(_on_settings_fullscreen_toggled)
	settings_panel.add_child(settings_fullscreen_check)

	settings_reduce_shake_check = CheckBox.new()
	settings_reduce_shake_check.text = "Reduce Shake"
	settings_reduce_shake_check.add_theme_color_override("font_color", Color("#15202b"))
	settings_reduce_shake_check.button_pressed = reduce_shake
	settings_reduce_shake_check.toggled.connect(_on_settings_reduce_shake_toggled)
	settings_panel.add_child(settings_reduce_shake_check)

	var back_button := _make_button("BACK TO MISSIONS", false)
	back_button.custom_minimum_size = Vector2(170, 28)
	back_button.add_theme_color_override("font_color", Color("#15202b"))
	back_button.pressed.connect(_hide_settings)
	settings_panel.add_child(back_button)


func _build_stat(caption: String, initial_value: String, value_color: Color) -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	stack.add_child(_make_label(caption, 9, MUTED))
	var value := _make_label(initial_value, 15, value_color)
	if caption == "PROGRAM BUDGET":
		budget_value = value
	else:
		science_value = value
	stack.add_child(value)
	return stack


func _refresh_interface() -> void:
	budget_value.text = _format_money(budget)
	science_value.text = "%d pts" % science
	_refresh_mission_list()
	_refresh_mission_details()


func _refresh_mission_list() -> void:
	_clear_container(mission_list)
	var selected_button: Button
	for index in range(GameData.MISSIONS.size()):
		var mission: Dictionary = GameData.MISSIONS[index]
		var is_locked: bool = index > completed_missions.size()
		var is_complete: bool = completed_missions.has(mission["id"])
		var state := "COMPLETE" if is_complete else ("LOCKED" if is_locked else "AVAILABLE")
		var button_text := "%02d %s\n%s • %s kg" % [
			index + 1,
			mission["name"],
			state,
			_format_mass(mission["mass_kg"]),
		]
		var button := _make_button(button_text, index == selected_mission_index)
		button.custom_minimum_size = Vector2(225, 52)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = is_locked
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var mission_index := index
		button.pressed.connect(func() -> void: _select_mission(mission_index))
		mission_list.add_child(button)
		if index == selected_mission_index:
			selected_button = button
	mission_phase_label.text = GameData.MISSIONS[selected_mission_index]["phase"]
	if selected_button != null:
		call_deferred("_reveal_mission_button", selected_button)


func _refresh_mission_details() -> void:
	_clear_container(mission_summary)
	_clear_container(detail_column)
	var mission: Dictionary = GameData.MISSIONS[selected_mission_index]
	var phase_label := _make_label(mission["phase"], 10, TEXT)
	mission_summary.add_child(phase_label)
	var name_label := _make_label(mission["name"], 20, TEXT)
	mission_summary.add_child(name_label)
	var brief_label := _make_label(mission["brief"], 12, TEXT)
	brief_label.custom_minimum_size.y = 42
	mission_summary.add_child(brief_label)
	mission_summary.add_child(_make_label(
		"CONTRACT  %s     MISSION SCIENCE  %d pts"
		% [_format_money(mission["reward"]), mission["science"]],
		11,
		TEXT
	))

	detail_column.add_child(_make_label("MISSION OBJECTIVES", 10, DETAIL_TEXT))
	for objective: String in mission["objectives"]:
		detail_column.add_child(_make_label("- " + objective, 10, DETAIL_TEXT))

	var instrument_label := _make_label("SCIENTIFIC INSTRUMENT  /  ALL AVAILABLE", 10, DETAIL_TEXT)
	detail_column.add_child(instrument_label)
	instrument_picker = OptionButton.new()
	instrument_picker.custom_minimum_size.y = 26
	instrument_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_picker(instrument_picker)
	for index in range(GameData.INSTRUMENTS.size()):
		var instrument: Dictionary = GameData.INSTRUMENTS[index]
		instrument_picker.add_item(
			"%s  |  %s kg  |  %s"
			% [instrument["name"], _format_mass(instrument["mass_kg"]), _format_money(instrument["cost"])]
		)
		instrument_picker.set_item_metadata(index, index)
	detail_column.add_child(instrument_picker)

	detail_column.add_child(_make_label("LAUNCH VEHICLE  /  ALL CLASSES AVAILABLE", 10, DETAIL_TEXT))
	launch_vehicle_picker = OptionButton.new()
	launch_vehicle_picker.custom_minimum_size.y = 26
	launch_vehicle_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_picker(launch_vehicle_picker)
	for index in range(GameData.VEHICLES.size()):
		var vehicle: Dictionary = GameData.VEHICLES[index]
		launch_vehicle_picker.add_item(
			"%s  |  %s kg  |  %s"
			% [vehicle["name"], _format_mass(vehicle["capacity_kg"]), _format_money(vehicle["cost"])]
		)
		launch_vehicle_picker.set_item_metadata(index, index)
	detail_column.add_child(launch_vehicle_picker)

	launch_status = _make_label("", 10, DETAIL_MUTED)
	launch_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(launch_status)
	launch_button = _make_button("LAUNCH MISSION", true, DETAIL_TEXT)
	launch_button.custom_minimum_size = Vector2(160, 30)
	launch_button.pressed.connect(_launch_selected_mission)
	detail_column.add_child(launch_button)
	instrument_picker.select(0)
	launch_vehicle_picker.select(_default_vehicle_index(mission, GameData.INSTRUMENTS[0]))
	instrument_picker.item_selected.connect(_update_launch_status)
	launch_vehicle_picker.item_selected.connect(_update_launch_status)
	_update_launch_status()


func _default_vehicle_index(mission: Dictionary, instrument: Dictionary) -> int:
	var required_mass: int = mission["mass_kg"] + instrument["mass_kg"]
	for index in range(GameData.VEHICLES.size()):
		if GameData.VEHICLES[index]["capacity_kg"] >= required_mass:
			return index
	return GameData.VEHICLES.size() - 1


func _update_launch_status(_selected_index: int = -1) -> void:
	var mission: Dictionary = GameData.MISSIONS[selected_mission_index]
	var vehicle: Dictionary = GameData.VEHICLES[launch_vehicle_picker.get_item_metadata(launch_vehicle_picker.selected)]
	var instrument: Dictionary = GameData.INSTRUMENTS[instrument_picker.get_item_metadata(instrument_picker.selected)]
	var total_mass: int = mission["mass_kg"] + instrument["mass_kg"]
	var total_cost: int = vehicle["cost"] + instrument["cost"]
	var is_complete: bool = completed_missions.has(mission["id"])

	if vehicle["capacity_kg"] < total_mass:
		launch_status.text = "Payload is %s kg. Select a launcher with more lift." % _format_mass(total_mass)
	elif total_cost > budget:
		launch_status.text = "%s required; current budget is %s." % [_format_money(total_cost), _format_money(budget)]
	elif is_complete:
		launch_status.text = "Mission complete. Replay available; no repeat money or science."
	else:
		launch_status.text = "Payload %s kg  /  Instrument science +%d pts" % [
			_format_mass(total_mass),
			instrument["science"],
		]

	launch_button.disabled = vehicle["capacity_kg"] < total_mass or total_cost > budget


func _select_mission(index: int) -> void:
	selected_mission_index = index
	_refresh_interface()


func _launch_selected_mission() -> void:
	var mission: Dictionary = GameData.MISSIONS[selected_mission_index]
	var vehicle: Dictionary = GameData.VEHICLES[launch_vehicle_picker.get_item_metadata(launch_vehicle_picker.selected)]
	var instrument: Dictionary = GameData.INSTRUMENTS[instrument_picker.get_item_metadata(instrument_picker.selected)]
	var total_mass: int = mission["mass_kg"] + instrument["mass_kg"]
	var total_cost: int = vehicle["cost"] + instrument["cost"]
	if vehicle["capacity_kg"] < total_mass or total_cost > budget:
		_update_launch_status()
		return
	var animation_name := StringName(vehicle["animation"])
	if not launch_sequence.has_animation(animation_name):
		push_error("The selected launch vehicle has no available rocket animation.")
		return

	budget -= total_cost
	pending_mission_index = selected_mission_index
	pending_mission_reward = mission["reward"]
	pending_mission_science = mission["science"] + instrument["science"]
	_start_launch_sequence(vehicle)


func _start_launch_sequence(vehicle: Dictionary) -> void:
	_reset_monitor_flicker()
	_set_monitor_ui_visibility(false)
	action_bar.hide()
	game_background.hide()
	launch_sequence.start_launch(
		StringName(vehicle["animation"]),
		GameData.MISSIONS[pending_mission_index]["name"],
		reduce_shake
	)


func _complete_launch() -> void:
	if pending_mission_index < 0:
		push_error("Cannot complete a launch without a pending mission.")
		return

	var mission: Dictionary = GameData.MISSIONS[pending_mission_index]
	if not completed_missions.has(mission["id"]):
		budget += pending_mission_reward
		science += pending_mission_science
		completed_missions.append(mission["id"])
		if completed_missions.size() < GameData.MISSIONS.size():
			selected_mission_index = completed_missions.size()
	_refresh_interface()


func _return_to_mission_screen() -> void:
	game_background.show()
	action_bar.show()
	_set_monitor_ui_visibility(true)
	_reset_monitor_flicker()


func _reveal_mission_button(button: Control) -> void:
	mission_scroll.ensure_control_visible(button)


func _show_quit_dialog() -> void:
	quit_dialog.popup_centered()


func _quit_game() -> void:
	get_tree().quit()


func _show_settings() -> void:
	_reset_monitor_flicker()
	settings_open = true
	_set_monitor_ui_visibility(false)
	settings_button.hide()
	settings_panel.show()


func _hide_settings() -> void:
	settings_open = false
	_set_monitor_ui_visibility(true)
	settings_button.show()
	settings_panel.hide()
	_reset_monitor_flicker()


func _track_monitor_ui(control: Control) -> void:
	monitor_ui_nodes.append(control)


func _set_monitor_ui_visibility(is_visible: bool) -> void:
	for control: Control in monitor_ui_nodes:
		control.visible = is_visible
	monitor_ui_flickering = false
	monitor_flicker_frames = 0


func _reset_monitor_flicker() -> void:
	_set_monitor_ui_visibility(true)
	monitor_flicker_timer = randf_range(3.0, 6.0)


func _update_monitor_flicker(delta: float) -> void:
	if settings_open or quit_dialog.visible:
		return

	if monitor_ui_flickering:
		monitor_flicker_frames -= 1
		if monitor_flicker_frames <= 0:
			monitor_ui_flickering = false
			_set_monitor_ui_visibility(true)
			monitor_flicker_timer = randf_range(3.0, 6.0)
		return

	monitor_flicker_timer -= delta
	if monitor_flicker_timer <= 0.0:
		_set_monitor_ui_visibility(false)
		monitor_ui_flickering = true
		monitor_flicker_frames = randi_range(2, 4)


func _on_settings_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value <= 0.01)


func _on_settings_fullscreen_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _on_settings_reduce_shake_toggled(toggled_on: bool) -> void:
	reduce_shake = toggled_on


func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label


func _style_picker(picker: OptionButton) -> void:
	picker.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	picker.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	picker.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	picker.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	picker.add_theme_color_override("font_color", DETAIL_TEXT)
	picker.add_theme_color_override("font_hover_color", DETAIL_TEXT)


func _make_button(text: String, highlighted: bool, text_color: Color = TEXT) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", _button_style(highlighted))
	button.add_theme_stylebox_override("hover", _button_style(true))
	button.add_theme_stylebox_override("pressed", _button_style(true))
	button.add_theme_stylebox_override("disabled", _button_style(false))
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return button


func _button_style(highlighted: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = ACCENT if highlighted else Color(0, 0, 0, 0)
	style.set_border_width_all(1 if highlighted else 0)
	style.set_corner_radius_all(3)
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	return style


func _format_money(amount: int) -> String:
	if amount < 1_000_000:
		return "$%dK" % int(amount / 1_000)
	if amount % 1_000_000 == 0:
		return "$%d M" % int(amount / 1_000_000)
	return "$%.1f M" % (float(amount) / 1_000_000.0)


func _format_mass(mass: int) -> String:
	var digits := str(mass)
	var formatted := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			formatted += ","
		formatted += digits[index]
	return formatted
