extends Control

const VIEWPORT_WIDTH: int = 860
const VIEWPORT_HEIGHT: int = 640
const STARTING_BUDGET: int = 20_000_000
const TEXT: Color = Color("#edf4fb")
const MUTED: Color = Color("#9aadc2")
const ACCENT: Color = Color("#72e0ad")
const GOLD: Color = Color("#f4c76b")
const DETAIL_TEXT: Color = Color("#15202b")
const DETAIL_MUTED: Color = Color("#34414c")

const VEHICLES: Array[Dictionary] = [
	{"name": "Small-lift launcher", "capacity_kg": 1500, "cost": 6_000_000, "animation": "small_lift"},
	{"name": "Medium-lift launcher", "capacity_kg": 20_000, "cost": 30_000_000, "animation": "medium_lift"},
	{"name": "Heavy-lift launcher", "capacity_kg": 65_000, "cost": 75_000_000, "animation": "heavy_lift"},
	{"name": "Super-heavy launcher", "capacity_kg": 100_000, "cost": 140_000_000, "animation": "super_heavy"},
]

const ROCKET_ANIMATION_FRAMES: Dictionary = {
	"small_lift": [
		"res://assets/small rocket/Small_OrbitRocket-1.png.png",
		"res://assets/small rocket/Small_OrbitRocket-2.png.png",
		"res://assets/small rocket/Small_OrbitRocket-3.png.png",
		"res://assets/small rocket/Small_OrbitRocket-4.png.png",
		"res://assets/small rocket/Small_OrbitRocket-5.png.png",
		"res://assets/small rocket/Small_OrbitRocket-6.png.png",
		"res://assets/small rocket/Small_OrbitRocket-7.png.png",
	],
	"medium_lift": [
		"res://assets/small rocket/MediumOrbitRocket1.png.png",
		"res://assets/small rocket/MediumOrbitRocket2.png.png",
		"res://assets/small rocket/MediumOrbitRocket3.png.png",
		"res://assets/small rocket/MediumOrbitRocket4.png.png",
		"res://assets/small rocket/MediumOrbitRocket5.png.png",
		"res://assets/small rocket/MediumOrbitRocket6.png.png",
	],
	"heavy_lift": [
		"res://assets/small rocket/LargeOrbitRocket1.png.png",
		"res://assets/small rocket/LargeOrbitRocket3.png.png",
		"res://assets/small rocket/LargeOrbitRocket6.png.png",
		"res://assets/small rocket/LargeOrbitRocket8.png.png",
	],
	"super_heavy": [
		"res://assets/small rocket/LargeOrbitRocket1.png.png",
		"res://assets/small rocket/LargeOrbitRocket2.png.png",
		"res://assets/small rocket/LargeOrbitRocket3.png.png",
		"res://assets/small rocket/LargeOrbitRocket4.png.png",
		"res://assets/small rocket/LargeOrbitRocket6.png.png",
		"res://assets/small rocket/LargeOrbitRocket7.png.png",
		"res://assets/small rocket/LargeOrbitRocket8.png.png",
	],
}

const LAUNCH_IDLE_DURATION: float = 1.0
const LAUNCH_SLOWDOWN_DURATION: float = 2.5
const LAUNCH_COMPLETE_DURATION: float = 2.0
const LAUNCH_START_Y: float = 530.0
const LAUNCH_TOP_Y: float = 64.0

const INSTRUMENTS: Array[Dictionary] = [
	{"name": "Communications Package", "mass_kg": 120, "cost": 500_000, "science": 5},
	{"name": "Optical Telescope", "mass_kg": 320, "cost": 1_200_000, "science": 20},
	{"name": "Multispectral Imager", "mass_kg": 180, "cost": 850_000, "science": 15},
	{"name": "Infrared Spectrometer", "mass_kg": 260, "cost": 1_100_000, "science": 25},
	{"name": "Ground-Penetrating Radar", "mass_kg": 450, "cost": 1_600_000, "science": 30},
	{"name": "Drill and Sample Analyzer", "mass_kg": 520, "cost": 2_000_000, "science": 35},
	{"name": "Mass Spectrometer", "mass_kg": 240, "cost": 1_300_000, "science": 28},
	{"name": "Laser Altimeter", "mass_kg": 160, "cost": 750_000, "science": 18},
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
	{
		"id": "lunar_relay",
		"name": "Lunar Relay Network",
		"phase": "PHASE 2  /  LUNAR EXPLORATION",
		"mass_kg": 1100,
		"reward": 25_000_000,
		"science": 35,
		"brief": "Place a relay satellite in lunar orbit so mission control can reach spacecraft on the Moon's far side.",
		"objectives": [
			"Launch a lunar communications relay.",
			"Establish a line-of-sight link around the Moon.",
			"Return the relay mission's science data.",
		],
	},
	{
		"id": "lunar_lander",
		"name": "First Lunar Landing",
		"phase": "PHASE 2  /  LUNAR EXPLORATION",
		"mass_kg": 3200,
		"reward": 45_000_000,
		"science": 55,
		"brief": "Land an uncrewed science craft on the Moon and prove the program can deliver payloads beyond Earth orbit.",
		"objectives": [
			"Deliver a lander to the lunar surface.",
			"Survive the landing and extreme thermal cycle.",
			"Transmit the first surface science results.",
		],
	},
	{
		"id": "lunar_rover",
		"name": "South Pole Rover",
		"phase": "PHASE 2  /  LUNAR EXPLORATION",
		"mass_kg": 5600,
		"reward": 55_000_000,
		"science": 70,
		"brief": "Explore the lunar south pole for water ice and mark a safe site for future surface missions.",
		"objectives": [
			"Land a rover near the lunar south pole.",
			"Survey for water ice and safe terrain.",
			"Send the site survey back to Earth.",
		],
	},
	{
		"id": "asteroid_miner",
		"name": "Asteroid Prospecting",
		"phase": "PHASE 3  /  OFF-WORLD INDUSTRY",
		"mass_kg": 26000,
		"reward": 85_000_000,
		"science": 95,
		"brief": "Rendezvous with a near-Earth asteroid and survey it for water ice and valuable metals.",
		"objectives": [
			"Rendezvous with the selected asteroid.",
			"Map its composition and accessible resources.",
			"Return the prospecting report to Earth.",
		],
	},
	{
		"id": "fuel_depot",
		"name": "Orbital Fuel Depot",
		"phase": "PHASE 3  /  OFF-WORLD INDUSTRY",
		"mass_kg": 36000,
		"reward": 110_000_000,
		"science": 110,
		"brief": "Deliver a modular fuel depot to orbit and prepare the first off-world supply chain.",
		"objectives": [
			"Deploy the orbital fuel depot.",
			"Store water-derived propellant in orbit.",
			"Demonstrate a future refueling destination.",
		],
	},
	{
		"id": "lunar_isru",
		"name": "Lunar ISRU Plant",
		"phase": "PHASE 4  /  LUNAR COLONIZATION",
		"mass_kg": 55000,
		"reward": 130_000_000,
		"science": 135,
		"brief": "Land an automated refinery to turn local regolith and ice into useful water, oxygen, and propellant.",
		"objectives": [
			"Deliver the refinery to a rover-surveyed site.",
			"Demonstrate local resource processing.",
			"Prepare the site for permanent habitation.",
		],
	},
	{
		"id": "lunar_colony",
		"name": "Lunar Research Outpost",
		"phase": "PHASE 4  /  LUNAR COLONIZATION",
		"mass_kg": 65000,
		"reward": 160_000_000,
		"science": 170,
		"brief": "Establish a powered lunar habitat and staffed research center at the surveyed south-pole site.",
		"objectives": [
			"Deploy habitat and research modules.",
			"Provide redundant surface power.",
			"Establish a permanent research outpost.",
		],
	},
	{
		"id": "mars_relay",
		"name": "Mars Communications",
		"phase": "PHASE 5  /  MARS COLONY",
		"mass_kg": 1800,
		"reward": 30_000_000,
		"science": 60,
		"brief": "Deploy communications spacecraft ahead of the first heavy Mars surface missions.",
		"objectives": [
			"Place relay spacecraft around Mars.",
			"Confirm reliable links with Earth.",
			"Prepare the network for surface operations.",
		],
	},
	{
		"id": "mars_rover",
		"name": "Mars Aquifer Survey",
		"phase": "PHASE 5  /  MARS COLONY",
		"mass_kg": 18000,
		"reward": 60_000_000,
		"science": 120,
		"brief": "Send an autonomous rover to identify water resources and a safe location for a future colony.",
		"objectives": [
			"Land an autonomous Mars rover.",
			"Survey candidate aquifer and landing sites.",
			"Transmit results despite signal delay.",
		],
	},
	{
		"id": "mars_colony",
		"name": "First Mars Colony",
		"phase": "PHASE 5  /  MARS COLONY",
		"mass_kg": 92000,
		"reward": 220_000_000,
		"science": 250,
		"brief": "Deliver the first autonomous colony modules, local fuel plant, and surface power system to Mars.",
		"objectives": [
			"Land colony modules at the surveyed site.",
			"Establish local fuel and reliable power.",
			"Prepare the habitat for a sustained crew.",
		],
	},
]

var budget: int = STARTING_BUDGET
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
var launch_background: Sprite2D
var launch_background_start_y: float = 0.0
var launch_background_end_y: float = 0.0
var launch_sprite: AnimatedSprite2D
var launch_message: Label
var launch_in_progress: bool = false
var launch_phase: StringName = &""
var launch_phase_elapsed: float = 0.0
var launch_shake_time: float = 0.0
var launch_animation_name: StringName = &""
var launch_ascent_duration: float = 0.0
var pending_mission_index: int = -1
var pending_mission_reward: int = 0
var pending_mission_science: int = 0

@onready var game_background: Sprite2D = $Sprite2D


func _ready() -> void:
	randomize()
	_build_interface()
	_build_launch_screen()
	_refresh_interface()


func _process(delta: float) -> void:
	if launch_in_progress:
		_update_launch_sequence(delta)
	else:
		_update_monitor_flicker(delta)


func _build_interface() -> void:
	custom_minimum_size = Vector2(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
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


func _build_launch_screen() -> void:
	launch_background = Sprite2D.new()
	launch_background.texture = preload("res://assets/RocketSimulation.png")
	launch_background.centered = true
	launch_background.scale = Vector2(10.0, 10.0)
	launch_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	launch_background.visible = false
	var scaled_background_height: float = launch_background.texture.get_height() * launch_background.scale.y
	launch_background_start_y = VIEWPORT_HEIGHT - scaled_background_height / 2.0
	launch_background_end_y = scaled_background_height / 2.0
	add_child(launch_background)

	var sprite_frames := SpriteFrames.new()
	sprite_frames.clear_all()
	for animation_key: String in ROCKET_ANIMATION_FRAMES.keys():
		sprite_frames.add_animation(animation_key)
		sprite_frames.set_animation_loop(animation_key, false)
		sprite_frames.set_animation_speed(animation_key, 1.0)
		var animation_textures: Array[Texture2D] = []
		for frame_path: String in ROCKET_ANIMATION_FRAMES[animation_key]:
			var frame_texture := ResourceLoader.load(frame_path) as Texture2D
			if frame_texture == null:
				push_error("Could not load rocket animation frame: %s" % frame_path)
				continue
			animation_textures.append(frame_texture)
			sprite_frames.add_frame(animation_key, frame_texture, 1.0)
		if animation_textures.is_empty():
			push_error("Rocket animation has no frames: %s" % animation_key)
		elif animation_textures.size() >= 2:
			var last_frame_index: int = animation_textures.size() - 1
			sprite_frames.add_frame(animation_key, animation_textures[last_frame_index - 1], 1.0)
			sprite_frames.add_frame(animation_key, animation_textures[last_frame_index], 1.0)
			for frame_index in range(last_frame_index - 1, -1, -1):
				sprite_frames.add_frame(animation_key, animation_textures[frame_index], 1.0)

	launch_sprite = AnimatedSprite2D.new()
	launch_sprite.sprite_frames = sprite_frames
	launch_sprite.centered = true
	launch_sprite.position = Vector2(VIEWPORT_WIDTH / 2.0, LAUNCH_START_Y)
	launch_sprite.scale = Vector2.ONE
	launch_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	launch_sprite.visible = false
	add_child(launch_sprite)

	launch_message = _make_label("", 16, TEXT)
	launch_message.position = Vector2(110, 564)
	launch_message.size = Vector2(640, 32)
	launch_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	launch_message.visible = false
	add_child(launch_message)


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
		button.custom_minimum_size = Vector2(225, 52)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = is_locked
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var mission_index := index
		button.pressed.connect(func() -> void: _select_mission(mission_index))
		mission_list.add_child(button)
		if index == selected_mission_index:
			selected_button = button
	mission_phase_label.text = MISSIONS[selected_mission_index]["phase"]
	if selected_button != null:
		call_deferred("_reveal_mission_button", selected_button)


func _refresh_mission_details() -> void:
	_clear_container(mission_summary)
	_clear_container(detail_column)
	var mission: Dictionary = MISSIONS[selected_mission_index]
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
	for index in range(INSTRUMENTS.size()):
		var instrument: Dictionary = INSTRUMENTS[index]
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
	for index in range(VEHICLES.size()):
		var vehicle: Dictionary = VEHICLES[index]
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
	launch_vehicle_picker.select(_default_vehicle_index(mission, INSTRUMENTS[0]))
	instrument_picker.item_selected.connect(_update_launch_status)
	launch_vehicle_picker.item_selected.connect(_update_launch_status)
	_update_launch_status()


func _default_vehicle_index(mission: Dictionary, instrument: Dictionary) -> int:
	var required_mass: int = mission["mass_kg"] + instrument["mass_kg"]
	for index in range(VEHICLES.size()):
		if VEHICLES[index]["capacity_kg"] >= required_mass:
			return index
	return VEHICLES.size() - 1


func _update_launch_status(_selected_index: int = -1) -> void:
	var mission: Dictionary = MISSIONS[selected_mission_index]
	var vehicle: Dictionary = VEHICLES[launch_vehicle_picker.get_item_metadata(launch_vehicle_picker.selected)]
	var instrument: Dictionary = INSTRUMENTS[instrument_picker.get_item_metadata(instrument_picker.selected)]
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
	var mission: Dictionary = MISSIONS[selected_mission_index]
	var vehicle: Dictionary = VEHICLES[launch_vehicle_picker.get_item_metadata(launch_vehicle_picker.selected)]
	var instrument: Dictionary = INSTRUMENTS[instrument_picker.get_item_metadata(instrument_picker.selected)]
	var total_mass: int = mission["mass_kg"] + instrument["mass_kg"]
	var total_cost: int = vehicle["cost"] + instrument["cost"]
	if vehicle["capacity_kg"] < total_mass or total_cost > budget:
		_update_launch_status()
		return
	var animation_name := StringName(vehicle["animation"])
	var has_rocket_animation: bool = launch_sprite.sprite_frames.has_animation(animation_name)
	if has_rocket_animation:
		has_rocket_animation = launch_sprite.sprite_frames.get_frame_count(animation_name) > 0
	if not has_rocket_animation:
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
	launch_background.show()
	launch_sprite.show()
	launch_message.show()

	launch_animation_name = StringName(vehicle["animation"])
	launch_sprite.animation = launch_animation_name
	launch_sprite.stop()
	launch_sprite.position = Vector2(VIEWPORT_WIDTH / 2.0, LAUNCH_START_Y)
	launch_background.position = Vector2(VIEWPORT_WIDTH / 2.0, launch_background_start_y)
	launch_ascent_duration = float(launch_sprite.sprite_frames.get_frame_count(launch_animation_name))
	launch_phase = &"idle"
	launch_phase_elapsed = 0.0
	launch_shake_time = 0.0
	launch_in_progress = true
	launch_message.text = "PRE-LAUNCH CHECKS  /  " + MISSIONS[pending_mission_index]["name"]


func _update_launch_sequence(delta: float) -> void:
	launch_phase_elapsed += delta
	match launch_phase:
		&"idle":
			if launch_phase_elapsed >= LAUNCH_IDLE_DURATION:
				launch_phase = &"ascent"
				launch_phase_elapsed = 0.0
				launch_sprite.play(launch_animation_name)
				launch_message.text = "IGNITION  /  ASCENT"
		&"ascent":
			var progress: float = minf(launch_phase_elapsed / launch_ascent_duration, 1.0)
			var eased_progress: float = 3.0 * progress * progress - 2.0 * progress * progress * progress
			launch_background.position.y = lerpf(launch_background_start_y, launch_background_end_y, eased_progress)
			launch_sprite.position.y = lerpf(LAUNCH_START_Y, LAUNCH_TOP_Y, eased_progress)
			var shake_multiplier: float = 0.35 if reduce_shake else 1.0
			var shake_amplitude: float = lerpf(11.0, 0.0, progress) * shake_multiplier
			var shake_speed: float = lerpf(18.0, 2.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= launch_ascent_duration:
				launch_background.position.y = launch_background_end_y
				launch_sprite.position.y = LAUNCH_TOP_Y
				launch_sprite.pause()
				launch_phase = &"slowdown"
				launch_phase_elapsed = 0.0
				launch_message.text = "ASCENT COMPLETE  /  VEHICLE COASTING"
		&"slowdown":
			var progress: float = minf(launch_phase_elapsed / LAUNCH_SLOWDOWN_DURATION, 1.0)
			launch_sprite.position.y = LAUNCH_TOP_Y
			var shake_multiplier: float = 0.35 if reduce_shake else 1.0
			var shake_amplitude: float = sin(progress * PI) * 5.0 * shake_multiplier
			var shake_speed: float = lerpf(8.0, 1.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= LAUNCH_SLOWDOWN_DURATION:
				launch_sprite.position.x = VIEWPORT_WIDTH / 2.0
				launch_sprite.position.y = LAUNCH_TOP_Y
				launch_phase = &"complete"
				launch_phase_elapsed = 0.0
				launch_message.text = "MISSION COMPLETE"
				_complete_launch()
		&"complete":
			if launch_phase_elapsed >= LAUNCH_COMPLETE_DURATION:
				_return_to_mission_screen()


func _apply_launch_shake(amplitude: float, shake_speed: float, delta: float) -> void:
	launch_shake_time += delta * shake_speed
	launch_sprite.position.x = VIEWPORT_WIDTH / 2.0 + sin(launch_shake_time) * amplitude


func _complete_launch() -> void:
	if pending_mission_index < 0:
		push_error("Cannot complete a launch without a pending mission.")
		return

	var mission: Dictionary = MISSIONS[pending_mission_index]
	if not completed_missions.has(mission["id"]):
		budget += pending_mission_reward
		science += pending_mission_science
		completed_missions.append(mission["id"])
		if completed_missions.size() < MISSIONS.size():
			selected_mission_index = completed_missions.size()
	_refresh_interface()


func _return_to_mission_screen() -> void:
	launch_in_progress = false
	launch_phase = &""
	launch_sprite.hide()
	launch_message.hide()
	launch_background.hide()
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
