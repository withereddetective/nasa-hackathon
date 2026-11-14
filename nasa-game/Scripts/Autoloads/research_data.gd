extends Node

var phase_one: Array[ResearchNodeInfo] = [
	ResearchNodeInfo.new(
		"placeholder one", "placeholder1", 1, "Places the holder."),
	ResearchNodeInfo.new(
		"placeholder two", "placeholder2", 1, "Holds the placer.", ["placeholder1"]),
	ResearchNodeInfo.new(
		"placeholder three", "placeholder3", 1, "Aces the polder.", ["placeholder1"]),
	ResearchNodeInfo.new(
		"placeholder four", "placeholder4", 1, "Four of them.", ["placeholder1"]),
	ResearchNodeInfo.new("placeholder five", "placeholder5", 1, "", ["placeholder2", "placeholder3"]),
	ResearchNodeInfo.new("placeholder six", "placeholder6", 1, ""),
]

var phase_two: Array[ResearchNodeInfo] = []

var all_phases: Array[ResearchNodeInfo] = \
	phase_one + phase_two

## Gets the [ResearchNodeInfo] with the given [param internal_name].
## If no node is found, null is returned.
func get_info(internal_name: String) -> ResearchNodeInfo:
	for info: ResearchNodeInfo in all_phases:
		if info.internal_name == internal_name:
			return info
	
	return null
