extends Resource
class_name Setting

enum SettingType {
	INT,
	FLOAT,
	STRING,
	BOOLEAN,
	NULL
}

var name: String
var type: SettingType = SettingType.NULL
var value: Variant
var default_value: Variant

func _init(
	setting_name: String,
	setting_default_value: Variant,
	setting_type: SettingType,
	setting_value: Variant = null) -> void:
	
	name = setting_name
	value = setting_value
	default_value = setting_default_value
	type = setting_type
	
	if not validate_data():
		push_error(
			"Setting of name %s is invalid; either value or default_value don't match the given type." \
			% [name]
		)

func set_value(new_value: Variant) -> void:
	if (type == SettingType.INT) and (new_value is float):
		#push_warning("Float getting put into setting %s will be converted to int." % [name])
		new_value = int(new_value)
	
	value = new_value
	if not validate_value(value):
		push_error(
			"Setting of name %s is invalid; value doesn't match the given type." \
			% [name]
		)

func get_value() -> Variant:
	if value == null:
		return default_value
	else:
		return value

func validate_value(validated: Variant) -> bool:
	match type:
		SettingType.INT:
			return validated is int
		SettingType.FLOAT:
			return validated is float or validated is int
		SettingType.STRING:
			return validated is String
		SettingType.BOOLEAN:
			return validated is bool
		_:
			push_warning(
				"Setting type is either NULL or not set. " + \
				"Make sure to set settings' type when making them;" + \
				"Validation always returns true when null."
			)
			return true

func validate_data() -> bool:
	return validate_value(default_value) and (value == null or validate_value(value))

func to_json() -> String:
	return "\"%s\": %s" % [name, get_value()]

func _to_string() -> String:
	return "Setting %s: %s" % [name, get_value()]
