extends GraphEdit
class_name ResearchTree

@export_file("*.tscn") var research_node_path: String

var all_nodes: Array[ResearchNode] = []

func find_node_by_internal(internal_name: String) -> ResearchNode:
	for node: ResearchNode in all_nodes:
		if node.data.internal_name == internal_name:
			return node
	
	return null

func turn_arr_to_nodes(internals: Array[String]) -> Array[ResearchNode]:
	var return_array: Array[ResearchNode] = []
	for internal_name: String in internals:
		return_array.append(find_node_by_internal(internal_name))
	
	return return_array

func load_all_research() -> void:
	for research_info: ResearchNodeInfo in ResearchData.phase_one:
		var current_node: ResearchNode = load(research_node_path).instantiate()
		
		current_node.data = research_info
		current_node.name = current_node.data.internal_name
		current_node.title = current_node.data.readable_name
		add_child(current_node)
		all_nodes.append(current_node)
	
	for node: ResearchNode in all_nodes:
		var info: ResearchNodeInfo = node.data
		var prerequisite_names: Array[String] = info.prerequisite_nodes
		var prerequisite_nodes: Array[ResearchNode] = \
			turn_arr_to_nodes(prerequisite_names)
		
		for prerequisite: ResearchNode in prerequisite_nodes:
			connect_node(prerequisite.name, 0, node.name, 0)

func _ready() -> void:
	load_all_research()
	arrange_nodes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
