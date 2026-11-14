extends Node
class_name ResearchNodeInfo

var readable_name: String
var internal_name: String
var research_cost: float
var description: String
## An [Array] of the nodes needed to unlock this node.
## Nodes needed are represented by their [member internal_name], not readable
var prerequisite_nodes: Array[String]

func _init(
		readable: String,
		internal: String,
		cost: float,
		descript: String,
		prerequisites: Array[String] = []) -> void:
	readable_name = readable
	internal_name = internal
	research_cost = cost
	description = descript
	prerequisite_nodes = prerequisites
