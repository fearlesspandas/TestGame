extends Control

onready var label = get_node("PlayerCount")
func _process(delta):
	label.text = "Connected: " + str(Server.connected_clients)
