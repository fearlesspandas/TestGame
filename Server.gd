extends Node

const DEFAULT_PORT = 8090
const MAX_CLIENTS = 10
export(Resource) var CharacterModel
export(Resource) var PlayerClientModel
export(Script) var EntityMovement
export(Script) var ClientPlayerMovement
var server = null
var client = null

var ip_address = ""
var connected_clients = 0
var player_positions = {}
var player_id:String = "Landon"
var player_input_queue : Array = []
onready var server_map = load("res://world_models/Blockofthing.tscn")
onready var client_map = load("res://ClientMap.tscn")
var map
func _ready():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168"):
			ip_address = ip
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
#func _process(delta):
#	if map != null:
#		print(map.get_child_count())
func create_server() -> void:
	print("creating server")
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	get_tree().set_network_peer(server)
	map = server_map.instance()
	map.set_name("Map")
	add_child(map)
func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,DEFAULT_PORT)
	map = client_map.instance()
	map.set_name("Map")
	get_tree().set_network_peer(client)
	add_child(map)
func _connected_to_server() -> void:
	rpc("increase_connected")
	rpc("add_player_entity",player_id)
	print("successfully connected")
func _server_disconnected() -> void:
	rpc("remove_player_entity",player_id)
	rpc("decrease_connected")
	print("disconnected from server")	
func add_player_client_model():
	var instance = load("res://entities/Marble.tscn").instance()
	instance.set_script(ClientPlayerMovement)
	instance.global_transform.origin = Vector3(0,1.5,0)
	instance.set_name(str(player_id))
	map.add_child(instance)
func client_get_player_position(id) -> Vector3 :
	return rpc_unreliable("get_player_position",id)
func client_get_player_basis(id) -> Vector3:
	return rpc_unreliable("get_player_basis",id)
remotesync func increase_connected():
	connected_clients += 1
remotesync func decrease_connected():
	connected_clients -= 1
remote func record_player_input(id,input,type):
	player_input_queue.append({"id":id,"input":input,"type":type})
remote func add_player_entity(id):
	
	var instance = load("res://entities/SphereCharacter.tscn").instance()
	instance.set_script(EntityMovement)
	instance.global_transform.origin = Vector3(0,0,0)
	instance.set_name(str(id))
	print("added character model")
	map.add_child(instance)
remote func remove_player_entity(id):
	var node = map.get_node(str(id))
	map.remove_child(node)
	if node != null:
		node.call_deferred("free")
remote func add_dest(id,loc,type):
	var player = map.get_node(str(id))
	if player != null:
		player.add_dest(loc,type)
remote func toggle_autopilot(id):
	var player = map.get_node(str(id))
	if player != null:
		player.toggle_autopilot()

remote func get_player_postion(id) -> Vector3:
	var player = get_node(str(id))
	if player!= null:
		return player.get_node("RigidBody").global_transform.origin
	else:
		return Vector3()
remote func get_player_basis(id) -> Dictionary:
	var player = get_node(str(id))
	if player!= null:
		var basis = player.get_node("RigidBody").global_transform.Basis
		return {"x":basis.x,"y":basis.y,"z":basis.z}
	else:
		return {}
func _on_startserver_toggled(button_pressed):
	if button_pressed:
		create_server()
	else:
		server = null
