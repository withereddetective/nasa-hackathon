extends TextureButton
class_name SkillTreeButton

var description: String
var cost: float

@export var info_box_control: Control
@export var info_box_description: RichTextLabel
@export var info_box_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _toggled(toggled_on: bool) -> void:
	info_box_control.visible = toggled_on
	info_box_description.text = "[font_size=24]%s[font_size]"% description
	info_box_button.text = "Buy (%s Research)" % cost
	

func buy_button() -> void:
	print("bought? (implement rejection if the user is BROKE)")
