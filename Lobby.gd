extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var SERVER_PORT = 4321
var MAX_PLAYERS = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
