extends Spatial

var device_ip_address
var create_server = false
var ip_in = "192.168.1.168"
onready var ip_label = find_node("IpLabel")
onready var pc_label = find_node("PClabel")
onready var control = find_node("Control")
onready var main = find_node("Main")
onready var player = find_node("P1").find_node("Player")
onready var camera = find_node("P1").find_node("PlayerCam")
export(Resource) var entity

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	device_ip_address = Server.ip_address
	Server.join_server()
	
func _physics_process(delta):
	pass

