

extends Node

# Connect all functions
#var device_ip_address
var create_server = false
onready var ip_in = find_node("IpIn")
onready var ip_label = find_node("IpLabel")
onready var pc_label = find_node("PClabel")
onready var control = find_node("Control")
onready var playerpos = find_node("playerpos")
onready var playerdest = find_node("playerdest"	)
onready var username = find_node("username")
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
func _process(delta):
	pc_label.text = str(Server.connected_clients)
	var poses = ""
	var dests = ""
	for p in Server.players.keys():
		poses += " " + str(p) + " location: " + str(Server.players[p].rigid.global_transform.origin)
		dests += " " + str(p) + " destinations: " + str(Server.players[p].dest)
	playerpos.text = poses 
	playerdest.text = dests
	Server.player_id = username.text
	if Input.is_action_just_pressed("escape"):
		control.visible = not control.visible
#func _player_connected():
#	print("player connected")
#func _player_disconnected():
#	print("player disconnected")


func _on_CheckButton_toggled(button_pressed):
	create_server = button_pressed


func _on_Button_button_down():
	if create_server:
		Server.create_server()
		ip_label.text = Server.ip_address
	else:
		if ip_in.text.length() > 0:
			Server.ip_address = ip_in.text
			Server.join_server()
			control.visible = false


func _on_username_text_changed():
	Server.player_id = username.text
