extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export(Resource) var Waypoint = load("res://selectors/selectionarea.tscn")
export(Resource) var Teleport = load("res://selectors/teleport_selection.tscn")

func get_resource_by_type(type) -> Resource:
	match type:
		"Waypoint":
			return Waypoint
		"Teleport":
			return Teleport
		_:
			return null
