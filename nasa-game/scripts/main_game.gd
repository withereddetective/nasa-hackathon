extends Control

const VIEWPORT_WIDTH: int = 860
const VIEWPORT_HEIGHT: int = 640
const STARTING_BUDGET: int = 20_000_000
const PANEL: Color = Color("#102238")
const PANEL_DARK: Color = Color("#0b1a2b")
const TEXT: Color = Color("#edf4fb")
const MUTED: Color = Color("#9aadc2")
const ACCENT: Color = Color("#72e0ad")
const GOLD: Color = Color("#f4c76b")

const VEHICLES: Array[Dictionary] = [
	{"name": "Small-lift launcher", "capacity_kg": 1500, "cost": 6_000_000},
	{"name": "Medium-lift launcher", "capacity_kg": 20_000, "cost": 30_000_000},
	{"name": "Heavy-lift launcher", "capacity_kg": 65_000, "cost": 75_000_000},
	{"name": "Super-heavy launcher", "capacity_kg": 100_000, "cost": 140_000_000},
]

const MISSIONS: Array[Dictionary] = [
	{
		"id": "first_satellite",
		"name": "First Satellite",
		"phase": "PHASE 1  /  ORBITAL FOUNDATIONS",
		"mass_kg": 280,
		"reward": 14_000_000,
		"science": 20,
		"brief": "Place a small communications satellite in low Earth orbit. A reliable first launch establishes the foundation for every mission that follows.",
		"objectives": [
			"Launch a 280 kg satellite to low Earth orbit.",
			"Keep the launch cost within the available budget.",
			"Return the first science data to mission control.",
		],
	},
	{
		"id": "space_telescope",
		"name": "Eyes on the Sky",
		"phase": "PHASE 1  /  ORBITAL FOUNDATIONS",
		"mass_kg": 920,
		"reward": 20_000_000,
		"science": 45,
		"brief": "Deploy an orbital space telescope. Its observations expand the science program and help identify future exploration targets.",
		"objectives": [
			"Launch the 920 kg telescope to orbit.",
			"Use its observations to earn 45 science.",
			"Complete the contract to unlock the station mission.",
		],
	},
	{
		"id": "station_core",
		"name": "Station Core",
		"phase": "PHASE 1  /  ORBITAL FOUNDATIONS",
		"mass_kg": 8200,
		"reward": 44_000_000,
		"science": 90,
		"brief": "Launch the first large module of a low Earth orbit station. This heavy payload introduces the medium-lift class and modular construction.",
		"objectives": [
			"Deliver an 8,200 kg station core to orbit.",
			"Select a vehicle with sufficient lift capacity.",
			"Complete the Phase 1 station contract.",
		],
	},
]

var budget: int = STARTING_BUDGET
var science: int = 0
var completed_missions: Array[String] = []
var selected_mission_index: int = 0

var budget_value: Label
var science_value: Label
var mission_list: VBoxContainer
var detail_column: VBoxContainer
var launch_vehicle_picker: OptionButton
var launch_button: Button
var launch_status: Label
var quit_dialog: ConfirmationDialog


func _ready() -> void:
	_build_interface()
	_refresh_interface()


func _build_interface() -> void:
	custom_minimum_size = Vector2(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)
	layout.add_child(_build_header())
	layout.add_child(_make_label("MISSION CONTROL  /  EARTH ORBIT", 11, ACCENT))

	var content := HBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size.y = 350
	content.add_theme_constant_override("separation", 20)
	var content_margin := MarginContainer.new()
	content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 74)
	content_margin.add_theme_constant_override("margin_right", 34)
	layout.add_child(content_margin)
	content_margin.add_child(content)
	content.add_child(_build_mission_panel())
	content.add_child(_build_detail_panel())
	_build_quit_dialog()


func _build_header() -> PanelContainer:
	var panel := _make_panel(PANEL)
	panel.custom_minimum_size.y = 68
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_stack.size_flags_stretch_ratio = 2.0
	title_stack.add_child(_make_label("ORBITAL PROGRAM", 18, TEXT))
	title_stack.add_child(_make_label("Build your first mission campaign", 11, MUTED))
	row.add_child(title_stack)
	row.add_child(_build_stat("PROGRAM BUDGET", "$0", ACCENT))
	row.add_child(_build_stat("SCIENCE", "0 pts", GOLD))

	var menu_button := _make_button("QUIT GAME", false)
	menu_button.custom_minimum_size.x = 120
	menu_button.pressed.connect(_show_quit_dialog)
	row.add_child(menu_button)
	return panel


func _build_quit_dialog() -> void:
	quit_dialog = ConfirmationDialog.new()
	quit_dialog.title = "Quit Game?"
	quit_dialog.dialog_text = "Are you sure you want to quit the game?"
	quit_dialog.ok_button_text = "Quit Game"
	quit_dialog.cancel_button_text = "Keep Playing"
	quit_dialog.confirmed.connect(_quit_game)
	add_child(quit_dialog)


func _build_stat(caption: String, initial_value: String, value_color: Color) -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.custom_minimum_size.x = 120
	stack.add_child(_make_label(caption, 9, MUTED))
	var value := _make_label(initial_value, 15, value_color)
	if caption == "PROGRAM BUDGET":
		budget_value = value
	else:
		science_value = value
	stack.add_child(value)
	return stack


func _build_mission_panel() -> PanelContainer:
	var panel := _make_panel(PANEL_DARK)
	panel.custom_minimum_size.x = 245
	panel.size_flags_stretch_ratio = 0.9
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	column.add_child(_make_label("PHASE 1", 10, ACCENT))
	column.add_child(_make_label("Orbital Foundations", 16, TEXT))
	column.add_child(_make_label("Complete contracts in order to grow your program.", 11, MUTED))
	mission_list = VBoxContainer.new()
	mission_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_list.add_theme_constant_override("separation", 7)
	column.add_child(mission_list)
	return panel


func _build_detail_panel() -> PanelContainer:
	var panel := _make_panel(PANEL)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = 1.6
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	detail_column = VBoxContainer.new()
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 10)
	scroll.add_child(detail_column)
	return panel


func _refresh_interface() -> void:
	budget_value.text = _format_money(budget)
	science_value.text = "%d pts" % science
	_refresh_mission_list()
	_refresh_mission_details()


func _refresh_mission_list() -> void:
	_clear_container(mission_list)
	for index in range(MISSIONS.size()):
		var mission: Dictionary = MISSIONS[index]
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
		button.custom_minimum_size = Vector2(0, 54)
		button.disabled = is_locked
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var mission_index := index
		button.pressed.connect(func() -> void: _select_mission(mission_index))
		mission_list.add_child(button)


func _refresh_mission_details() -> void:
	_clear_container(detail_column)
	var mission: Dictionary = MISSIONS[selected_mission_index]
	detail_column.add_child(_make_label(mission["phase"], 10, ACCENT))
	detail_column.add_child(_make_label(mission["name"], 20, TEXT))
	detail_column.add_child(_make_label(mission["brief"], 12, MUTED))

	var stats := HBoxContainer.new()
	stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_theme_constant_override("separation", 8)
	stats.add_child(_build_detail_stat("PAYLOAD MASS", _format_mass(mission["mass_kg"])))
	stats.add_child(_build_detail_stat("CONTRACT", _format_money(mission["reward"])))
	stats.add_child(_build_detail_stat("SCIENCE", "%d pts" % mission["science"]))
	detail_column.add_child(stats)

	detail_column.add_child(_make_label("MISSION OBJECTIVES", 11, GOLD))
	for objective: String in mission["objectives"]:
		detail_column.add_child(_make_label("- " + objective, 12, TEXT))

	detail_column.add_child(_make_label("LAUNCH VEHICLE", 11, GOLD))
	launch_vehicle_picker = OptionButton.new()
	launch_vehicle_picker.custom_minimum_size.y = 34
	launch_vehicle_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.add_child(launch_vehicle_picker)

	launch_status = _make_label("", 11, MUTED)
	launch_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_column.add_child(launch_status)
	launch_button = _make_button("LAUNCH MISSION", true)
	launch_button.custom_minimum_size.y = 40
	launch_button.pressed.connect(_launch_selected_mission)
	detail_column.add_child(launch_button)
	_populate_vehicle_picker(mission)


func _build_detail_stat(caption: String, value: String) -> PanelContainer:
	var panel := _make_panel(PANEL_DARK)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.x = 120
	var stack := VBoxContainer.new()
	stack.add_child(_make_label(caption, 9, MUTED))
	stack.add_child(_make_label(value, 14, TEXT))
	panel.add_child(stack)
	return panel


func _populate_vehicle_picker(mission: Dictionary) -> void:
	launch_vehicle_picker.clear()
	var available_count := 0
	for index in range(VEHICLES.size()):
		var vehicle: Dictionary = VEHICLES[index]
		if vehicle["capacity_kg"] < mission["mass_kg"] or vehicle["cost"] > budget:
			continue
		var item_index := launch_vehicle_picker.item_count
		launch_vehicle_picker.add_item(
			"%s  |  up to %s kg  |  %s"
			% [vehicle["name"], _format_mass(vehicle["capacity_kg"]), _format_money(vehicle["cost"])]
		)
		launch_vehicle_picker.set_item_metadata(item_index, index)
		available_count += 1

	var is_complete: bool = completed_missions.has(mission["id"])
	if available_count == 0:
		launch_vehicle_picker.add_item("No affordable vehicle with sufficient lift")
		launch_vehicle_picker.disabled = true
		launch_button.disabled = true
		launch_status.text = "Earn more funds or select a lighter mission."
	elif is_complete:
		launch_vehicle_picker.disabled = true
		launch_button.disabled = true
		launch_status.text = "Contract complete. Select the next available mission."
	else:
		launch_vehicle_picker.disabled = false
		launch_button.disabled = false
		launch_vehicle_picker.select(0)
		launch_status.text = "A successful launch earns the contract payout and science."


func _select_mission(index: int) -> void:
	selected_mission_index = index
	_refresh_interface()


func _launch_selected_mission() -> void:
	var mission: Dictionary = MISSIONS[selected_mission_index]
	if completed_missions.has(mission["id"]):
		return
	if launch_vehicle_picker.item_count == 0 or launch_vehicle_picker.disabled:
		return

	var vehicle_index: int = launch_vehicle_picker.get_item_metadata(launch_vehicle_picker.selected)
	var vehicle: Dictionary = VEHICLES[vehicle_index]
	if vehicle["capacity_kg"] < mission["mass_kg"] or vehicle["cost"] > budget:
		push_error("The selected launch vehicle cannot carry this mission within the available budget.")
		return

	budget -= vehicle["cost"]
	budget += mission["reward"]
	science += mission["science"]
	completed_missions.append(mission["id"])
	if completed_missions.size() < MISSIONS.size():
		selected_mission_index = completed_missions.size()
	_refresh_interface()


func _show_quit_dialog() -> void:
	quit_dialog.popup_centered()


func _quit_game() -> void:
	get_tree().quit()


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


func _make_panel(fill: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill.r, fill.g, fill.b, 0.82)
	style.border_color = Color("#23384d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _make_button(text: String, highlighted: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_stylebox_override("normal", _button_style(PANEL, highlighted))
	button.add_theme_stylebox_override("hover", _button_style(Color("#19344a"), true))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#1b3d4d"), true))
	button.add_theme_stylebox_override("disabled", _button_style(PANEL_DARK, false))
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return button


func _button_style(fill: Color, highlighted: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill.r, fill.g, fill.b, 0.84)
	style.border_color = ACCENT if highlighted else Color("#23384d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	return style


func _format_money(amount: int) -> String:
	return "$%s M" % _format_mass(int(amount / 1_000_000))


func _format_mass(mass: int) -> String:
	var digits := str(mass)
	var formatted := ""
	for index in range(digits.length()):
		if index > 0 and (digits.length() - index) % 3 == 0:
			formatted += ","
		formatted += digits[index]
	return formatted
