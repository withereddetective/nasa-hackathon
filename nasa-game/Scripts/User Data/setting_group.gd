extends Resource
class_name SettingGroup

var name: String
var settings: Array[Setting]
var setting_groups: Array[SettingGroup]

func _init(
	group_name: String,
	group_settings: Array[Setting],
	nested_groups: Array[SettingGroup] = []) -> void:
	
	name = group_name
	settings = group_settings
	setting_groups = nested_groups

func to_json(add_name: bool = true) -> String:
	var json_strings: Array[String]
	
	for group: SettingGroup in setting_groups:
		json_strings.append(group.to_json())
	
	for setting: Setting in settings:
		json_strings.append(setting.to_json())
	
	if not add_name:
		return "{%s}" % [",\n".join(json_strings)]
	
	return "\"%s\": {%s}" % [name, ",\n".join(json_strings)]
