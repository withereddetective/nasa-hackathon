extends Node2D

signal award_mission
signal finished

const GameData = preload("res://Scripts/game_data.gd")
const MainGame = preload("res://Scripts/main_game.gd")

const TEXT: Color = Color("#edf4fb")
const LAUNCH_IDLE_DURATION: float = 1.0
const LAUNCH_SLOWDOWN_DURATION: float = 2.5
const LAUNCH_COMPLETE_DURATION: float = 2.0
const LAUNCH_START_Y: float = 530.0
const LAUNCH_TOP_Y: float = 64.0
const LAUNCH_FAILURE_SLOWDOWN_DURATION: float = 1.5
const LAUNCH_FAILURE_FALL_DURATION: float = 2.5
const LAUNCH_FAILURE_PROGRESS: float = 0.55
const REDUCED_SHAKE_FACTOR: float = 0.1

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

var launch_background: Sprite2D
var launch_background_start_y: float = 0.0
var launch_background_end_y: float = 0.0
var launch_sprite: AnimatedSprite2D
var launch_message: Label
var launch_in_progress: bool = false
var reduce_shake: bool = false
var mission_success: bool = true
var launch_phase: StringName = &""
var launch_phase_elapsed: float = 0.0
var launch_shake_time: float = 0.0
var launch_animation_name: StringName = &""
var launch_ascent_duration: float = 0.0
var rotate_tween_started: bool = false
var failure_fall_start_y: float = 0.0
var failure_fall_start_background_y: float = 0.0


func _ready() -> void:
	_build_launch_screen()


func _build_launch_screen() -> void:
	launch_background = Sprite2D.new()
	launch_background.texture = preload("res://assets/RocketSimulation.png")
	launch_background.centered = true
	launch_background.scale = Vector2(10.0, 10.0)
	launch_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	launch_background.visible = false
	var scaled_background_height: float = launch_background.texture.get_height() * launch_background.scale.y
	launch_background_start_y = GameData.VIEWPORT_HEIGHT - scaled_background_height / 2.0
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
	launch_sprite.position = Vector2(GameData.VIEWPORT_WIDTH / 2.0, LAUNCH_START_Y)
	launch_sprite.scale = Vector2.ONE
	launch_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	launch_sprite.visible = false
	launch_sprite.rotation = 0
	add_child(launch_sprite)

	launch_message = Label.new()
	launch_message.text = ""
	launch_message.add_theme_font_size_override("font_size", 16)
	launch_message.add_theme_color_override("font_color", TEXT)
	launch_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	launch_message.clip_text = true
	launch_message.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	launch_message.position = Vector2(110, 564)
	launch_message.size = Vector2(640, 32)
	launch_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	launch_message.visible = false
	add_child(launch_message)


func has_animation(animation_name: StringName) -> bool:
	return (
		launch_sprite.sprite_frames.has_animation(animation_name)
		and launch_sprite.sprite_frames.get_frame_count(animation_name) > 0
	)


func is_running() -> bool:
	return launch_in_progress


func start_launch(
	animation_name: StringName,
	mission_name: String,
	mission_succeeded: bool,
	reduce_shake_enabled: bool
) -> void:
	if not has_animation(animation_name):
		push_error("The selected launch vehicle has no available rocket animation.")
		return

	reduce_shake = reduce_shake_enabled
	mission_success = mission_succeeded
	launch_animation_name = animation_name
	launch_sprite.animation = launch_animation_name
	launch_sprite.stop()
	launch_sprite.position = Vector2(GameData.VIEWPORT_WIDTH / 2.0, LAUNCH_START_Y)
	launch_background.position = Vector2(GameData.VIEWPORT_WIDTH / 2.0, launch_background_start_y)
	launch_background.show()
	launch_sprite.show()
	launch_message.show()
	launch_message.text = "PRE-LAUNCH CHECKS  /  " + mission_name

	launch_ascent_duration = float(launch_sprite.sprite_frames.get_frame_count(launch_animation_name))
	launch_phase = &"idle"
	launch_phase_elapsed = 0.0
	launch_shake_time = 0.0
	launch_in_progress = true


func _process(delta: float) -> void:
	if not launch_in_progress:
		return

	launch_phase_elapsed += delta
	match launch_phase:
		&"idle":
			if launch_phase_elapsed >= LAUNCH_IDLE_DURATION:
				launch_phase = &"ascent"
				launch_phase_elapsed = 0.0
				launch_sprite.play(launch_animation_name)
				launch_message.text = "IGNITION  /  ASCENT"
		&"ascent":
			var ascent_duration: float = launch_ascent_duration
			var destination_progress: float = 1.0
			if not mission_success:
				ascent_duration *= LAUNCH_FAILURE_PROGRESS
				destination_progress = LAUNCH_FAILURE_PROGRESS
			var progress: float = minf(launch_phase_elapsed / ascent_duration, 1.0)
			var eased_progress: float = 3.0 * progress * progress - 2.0 * progress * progress * progress
			var path_progress: float = eased_progress * destination_progress
			launch_background.position.y = lerpf(launch_background_start_y, launch_background_end_y, path_progress)
			launch_sprite.position.y = lerpf(LAUNCH_START_Y, LAUNCH_TOP_Y, path_progress)
			var shake_multiplier: float = REDUCED_SHAKE_FACTOR if reduce_shake else 1.0
			var shake_amplitude: float = lerpf(11.0, 0.0, progress) * shake_multiplier
			var shake_speed: float = lerpf(18.0, 2.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= ascent_duration:
				launch_background.position.y = lerpf(
					launch_background_start_y,
					launch_background_end_y,
					destination_progress
				)
				launch_sprite.position.y = lerpf(LAUNCH_START_Y, LAUNCH_TOP_Y, destination_progress)
				launch_sprite.pause()
				launch_phase_elapsed = 0.0
				if mission_success:
					launch_phase = &"slowdown"
					launch_message.text = "ASCENT COMPLETE  /  VEHICLE COASTING"
				else:
					launch_phase = &"failure_slowdown"
					launch_message.text = "ENGINE FAILURE  /  ASCENT ABORTED"
			elif launch_phase_elapsed >= launch_ascent_duration - 1:
				if not rotate_tween_started:
					rotate_tween_started = true
					var rotate_tween: Tween = get_tree().create_tween()
					rotate_tween.set_ease(Tween.EASE_IN_OUT)
					rotate_tween.tween_property(launch_sprite, "rotation", launch_sprite.rotation + PI, 1)
		&"slowdown":
			var progress: float = minf(launch_phase_elapsed / LAUNCH_SLOWDOWN_DURATION, 1.0)
			launch_sprite.position.y = LAUNCH_TOP_Y
			var shake_multiplier: float = REDUCED_SHAKE_FACTOR if reduce_shake else 1.0
			var shake_amplitude: float = sin(progress * PI) * 5.0 * shake_multiplier
			var shake_speed: float = lerpf(8.0, 1.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= LAUNCH_SLOWDOWN_DURATION:
				launch_sprite.position.x = GameData.VIEWPORT_WIDTH / 2.0
				launch_sprite.position.y = LAUNCH_TOP_Y
				launch_phase = &"complete"
				launch_phase_elapsed = 0.0
				launch_message.text = "MISSION COMPLETE"
				award_mission.emit()
		&"failure_slowdown":
			var progress: float = minf(launch_phase_elapsed / LAUNCH_FAILURE_SLOWDOWN_DURATION, 1.0)
			var shake_multiplier: float = REDUCED_SHAKE_FACTOR if reduce_shake else 1.0
			var shake_amplitude: float = lerpf(4.0, 8.0, progress) * shake_multiplier
			var shake_speed: float = lerpf(7.0, 3.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= LAUNCH_FAILURE_SLOWDOWN_DURATION:
				failure_fall_start_y = launch_sprite.position.y
				failure_fall_start_background_y = launch_background.position.y
				launch_phase = &"failure_fall"
				launch_phase_elapsed = 0.0
				launch_message.text = "ROCKET FALLING BACK TO EARTH"
		&"failure_fall":
			var progress: float = minf(launch_phase_elapsed / LAUNCH_FAILURE_FALL_DURATION, 1.0)
			var eased_progress: float = progress * progress
			launch_sprite.position.y = lerpf(failure_fall_start_y, LAUNCH_START_Y, eased_progress)
			launch_background.position.y = lerpf(
				failure_fall_start_background_y,
				launch_background_start_y,
				eased_progress
			)
			var shake_multiplier: float = REDUCED_SHAKE_FACTOR if reduce_shake else 1.0
			var shake_amplitude: float = lerpf(8.0, 14.0, progress) * shake_multiplier
			var shake_speed: float = lerpf(4.0, 12.0, progress)
			_apply_launch_shake(shake_amplitude, shake_speed, delta)
			if launch_phase_elapsed >= LAUNCH_FAILURE_FALL_DURATION:
				launch_sprite.position = Vector2(GameData.VIEWPORT_WIDTH / 2.0, LAUNCH_START_Y)
				launch_background.position.y = launch_background_start_y
				launch_phase = &"complete"
				launch_phase_elapsed = 0.0
				launch_message.text = "MISSION FAILED"
		&"complete":
			if launch_phase_elapsed >= LAUNCH_COMPLETE_DURATION:
				launch_in_progress = false
				launch_phase = &""
				launch_sprite.hide()
				launch_message.hide()
				launch_background.hide()
				finished.emit()


func _apply_launch_shake(amplitude: float, shake_speed: float, delta: float) -> void:
	launch_shake_time += delta * shake_speed
	launch_sprite.position.x = GameData.VIEWPORT_WIDTH / 2.0 + sin(launch_shake_time) * amplitude



func _Mission_Result(selected_mission_index: int, selected_vehicle_index: int, selected_instrument_index: int) -> bool: 

	var success: bool = true

	var current_Mission = GameData.MISSIONS[selected_mission_index]
	var vehicle = GameData.VEHICLES[selected_vehicle_index]
	var instrument = GameData.INSTRUMENTS[selected_instrument_index]
	var total_cost = vehicle["cost"] +  instrument["cost"]
	
	if vehicle["capacity_kg"] < current_Mission["mass.kg"] || ResearchData.science < current_Mission["science_required"] || MainGame.budget < total_cost:
		success = false
		
	return success

func _Mission_Summary(success) -> void:
	
	if success == false:
		launch_message.text = "Mission Failed"
		