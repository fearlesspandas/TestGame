

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
#func _ready():
#	get_tree().connect("network_peer_connected", self, "_player_connected")
#	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
#	get_tree().connect("connected_to_NetworkManager", self, "_connected_to_NetworkManager")
#	get_tree().connect("NetworkManager_disconnected", self, "_NetworkManager_disconnected")
func _process(delta):
	if get_tree().is_network_server():
		pc_label.text = str(ServerManager.connected_clients)
		var poses = ""
		var dests = ""
		for p in ServerManager.players.keys():
			poses += " " + str(p) + " location: " + str(ServerManager.players[p].rigid.global_transform.origin)
			dests += " " + str(p) + " destinations: " + str(ServerManager.players[p].dest)
		playerpos.text = poses 
		playerdest.text = dests
	

func _on_CheckButton_toggled(button_pressed):
	create_server = button_pressed


func _on_Button_button_down():
	if create_server:
		NetworkManager.create_server()
		ip_label.text = ServerManager.ip_address
	else:
		if ip_in.text.length() > 0:
			ClientManager.player_id = username.text
			ClientManager.ip_address = ip_in.text
			NetworkManager.join_server()
			control.visible = false


func _on_username_text_changed():
	ClientManager.player_id = username.text


func _on_LogoutButton_pressed():
	NetworkManager.kicked()
