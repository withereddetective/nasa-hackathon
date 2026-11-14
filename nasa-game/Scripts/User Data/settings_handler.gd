## Because this is an autoload, you can get and save settings at any time.
## please make use of this pretty please
extends Node

## The path to the user folder where settings will be stored.
const settings_path: StringName = &"user://settings.json"

## Where all the settings of the project are stored.
var settings: SettingGroup = SettingGroup.new("master_settings",
	[ ## Single Settings
	Setting.new("placeholder", 10, Setting.SettingType.FLOAT)
	],
	[ ## Setting Groups
	SettingGroup.new("sound",
		[Setting.new("master_volume", 50, Setting.SettingType.FLOAT),
		Setting.new("music_volume", 100, Setting.SettingType.FLOAT),
		Setting.new("sound_effect_volume", 100, Setting.SettingType.FLOAT)]
	)
	]
)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	read_settings_from_json()
	save_current_settings_to_json()

## Similar to settings.to_json(false) but formatted alot better
## Likely for saving to the settings file :aga:
func create_string_from_settings(indent: String = "  ") -> String:
	return JSON.stringify(
		JSON.parse_string(settings.to_json(false)),
		indent
	)

func get_setting_with_name(name_to_find: String, setting_group: SettingGroup = null) -> Setting:
	if setting_group == null:
		setting_group = settings
	
	for setting: Setting in setting_group.settings:
		if setting.name == name_to_find:
			return setting
	
	return null

func get_group_with_name(name_to_find: String, setting_group: SettingGroup = null) -> SettingGroup:
	if setting_group == null:
		setting_group = settings
	
	for group: SettingGroup in setting_group.setting_groups:
		if group.name == name_to_find:
			return group
	
	return null

func _parse_settings(
		settings_dict: Dictionary,
		setting_group: SettingGroup = null
	) -> void:
	if setting_group == null:
		setting_group = settings
	
	for key: String in settings_dict.keys():
		var value: Variant = settings_dict[key]
		var gotten_setting: Setting = get_setting_with_name(key, setting_group)
		
		if gotten_setting != null:
			gotten_setting.set_value(value)
			continue
		
		var gotten_group: SettingGroup = get_group_with_name(key, setting_group)
		
		if gotten_group != null and (value is Dictionary):
			_parse_settings(value, gotten_group)
			continue
		
		push_warning(
			"Setting or group %s in the settings.json file does not exist in the hard-coded settings. " \
			+ "It will be (hopefully) removed the next time settings are saved." \
			% [key]
		)

func read_settings_from_json() -> void:
	var settings_reader: FileAccess = FileAccess.open(settings_path, FileAccess.READ)
	# If settings haven't been created yet or the file couldn't be opened for other reasons
	if settings_reader == null:
		var error: Error = FileAccess.get_open_error()
		var error_str = "%s %s" % [CommonScripts.a_or_an_from(error_string(error)), error_string(error)]
		push_warning("Couldn't find the settings file at %s because of %s error." % [settings_path, error_str])
		return
	
	var settings_text: String = settings_reader.get_as_text()
	var settings_dict: Dictionary = JSON.parse_string(settings_text)
	
	if settings_dict == null:
		return
	_parse_settings(settings_dict, settings)

func save_current_settings_to_json() -> void:
	var settings_string: String = create_string_from_settings()
	var settings_file: FileAccess = FileAccess.open(settings_path, FileAccess.WRITE)
	settings_file.store_string(settings_string)

## The [param setting_path] is the path to the setting,
## seperated by [param separator], which is periods by default. [br]
## example for setting_path: [code]visual.trail.enabled[/code] [br]
## if the setting is not found, an error is pushed and [code]null[/code] is returned.
func get_setting(setting_path: String, separator: String = ".") -> Setting:
	var split_path: PackedStringArray = setting_path.split(separator)
	var current_group: SettingGroup = settings
	
	for path_item_name: String in split_path.slice(0, -1):
		var setting_group: SettingGroup = get_group_with_name(path_item_name, current_group)
		if setting_group == null:
			push_error("The group \"%s\" in the path \"%s\" could not be found." \
				% [path_item_name, setting_path])
			return null
		
		current_group = setting_group
	
	var found_setting = get_setting_with_name(split_path[-1], current_group)
	if found_setting == null:
		push_error("The setting \"%s\" in the path \"%s\" could not be found."
			% [split_path[-1], setting_path])
		return null
	
	return found_setting

## Similar to [method get_setting], but gets the value of the setting instead. [br]
## The [param setting_path] is the path to the setting,
## seperated by [param separator], which is periods by default. [br]
## example for setting_path: [code]visual.trail.enabled[/code] [br]
## if the setting is not found, an error is pushed and [code]null[/code] is returned.
func get_setting_value(setting_path: String, separator: String = ".") -> Variant:
	var gotten_setting: Setting = get_setting(setting_path, separator)
	if gotten_setting == null:
		return null
	return gotten_setting.get_value()

## Sets the setting at [param setting_path] to [param new_value].
## The [param setting_path] is seperated by [param separator],
## which is periods by default. [br]
## example for setting_path: [code]visual.trail.enabled[/code] [br]
## if the setting is not found, an error is pushed and no setting is set.
func set_setting(setting_path: String, new_value: Variant, separator: String = ".") -> void:
	var gotten_setting: Setting = get_setting(setting_path, separator)
	if gotten_setting == null:
		# only a warning cause an error is already thrown if this happens
		push_warning("Can't set setting at path %s due to it not existing." \
			% [setting_path])
		return
	
	gotten_setting.set_value(new_value)
