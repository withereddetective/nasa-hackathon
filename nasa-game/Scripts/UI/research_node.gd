extends GraphNode
class_name ResearchNode

@export_file("*.tscn") var path_to_skill_tree_button: String

var data: ResearchNodeInfo

func set_user_lock(locked: bool = true) -> void:
	var not_locked = not locked
	draggable = not_locked
	selectable = not_locked
	resizable = not_locked
	mouse_filter = Control.MOUSE_FILTER_PASS

func _add_description_button(text: String, cost: float) -> void:
	var skill_tree_button: SkillTreeButton = load(path_to_skill_tree_button).instantiate()
	skill_tree_button.set_deferred("description", text)
	skill_tree_button.set_deferred("cost", cost)
	add_child.call_deferred(skill_tree_button)

func _init() -> void:
	set_user_lock(true)

func _ready() -> void:
	_add_description_button(data.description, data.research_cost)
	var row_label: Label = Label.new()
	add_child(row_label)
	var has_input: bool = len(data.prerequisite_nodes) > 0
	
	set_slot(0, has_input, 0, Color.DARK_ORANGE, true, 0, Color.BLUE)

func _process(delta: float) -> void:
	pass
