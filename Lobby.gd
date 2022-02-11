

extends Node

# Connect all functions
var device_ip_address
var create_server = false
var ip_in = "192.168.1.168"
onready var ip_label = find_node("IpLabel")
onready var pc_label = find_node("PClabel")
onready var control = find_node("Control")
onready var playerpos = find_node("playerpos")
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	device_ip_address = Server.ip_address
	
	
	
func _process(delta):
	pc_label.text = str(Server.connected_clients)
	playerpos.text = "player positions : " + str(Server.player_positions)
	if Input.is_action_just_pressed("escape"):
		control.visible = not control.visible
func _player_connected():
	print("player connected")
func _player_disconnected():
	print("player disconnected")


func _on_CheckButton_toggled(button_pressed):
	create_server = button_pressed


func _on_Button_button_down():
	if create_server:
		Server.create_server()
	else:
		Server.ip_address = ip_in
		ip_label.text = "connecting:" + Server.ip_address 
		Server.join_server()
		control.visible = false
