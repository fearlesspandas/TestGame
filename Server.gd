extends Node

const DEFAULT_PORT = 8090
const MAX_CLIENTS = 10
export(Resource) var CharacterModel
export(Resource) var PlayerClientModel
#export(Script) var EntityMovement
export(Script) var ClientPlayerMovement
var server = null
var client = null
var players = {}
var player_id_relations = {}
var ip_address = ""
var connected_clients = 0

var player_input_queue = []
var player_id:String = "Player"
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
	map.global_transform.origin = Vector3()
	add_child(map)
	
func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server() -> void:
	rpc("increase_connected")
	rpc("add_player_entity",player_id)
	map = client_map.instance()
	map.set_name("Map")
	map.global_transform.origin = Vector3()
	add_player_client_model()
	add_child(map)
	print("successfully connected")
	
func _server_disconnected() -> void:
	rpc("remove_player_entity",player_id)
	rpc("decrease_connected")
	print("disconnected from server")	
	
func add_player_client_model():
	var instance = load("res://ClientMarble.tscn").instance()
#	instance.set_script(ClientPlayerMovement)
	instance.global_transform.origin = Vector3(0,5,0)
	instance.set_name("P1")
	map.add_child(instance)
	
remote func set_client_player_pos(loc:Vector3,rot):
	map.get_node("P1").get_node("Player").move_towards_loc(loc,rot)
	
remote func set_client_rotation_deg(rot):
	map.get_node("P1").get_node("Player").set_rotation_degrees(rot)
	
remote func set_client_player_basis(basis:Basis):
	map.get_node("P1").get_node("Player").rigid.global_transform.basis = basis
	
func server_set_client_rotation_deg(id,rot):
	var rid = player_id_relations[id]
	rpc_unreliable_id(rid,"set_client_rotation_deg",rot)
	
func server_set_client_player_pos(id,loc,rot):
	var rid = player_id_relations[id]
	rpc_unreliable_id(rid,"set_client_player_pos",loc,rot)
	
func server_set_client_player_basis(id,basis:Basis):
	var rid = player_id_relations[id]
	rpc_unreliable_id(rid,"set_client_player_basis",basis)
	
func client_add_dest(id,loc,type):
	rpc("add_dest",id,loc,type)
	
func client_move_entity(path:Vector3,id):
	rpc_unreliable("server_move_entity",path,id)
	
remote func server_move_entity(path:Vector3,id):
	players[id].handle_dir(path)
	
remotesync func increase_connected():
	connected_clients += 1
	
remotesync func decrease_connected():
	connected_clients -= 1
	
remote func record_player_input(id,input,type):
	player_input_queue.append({"id":id,"input":input,"type":type})
	
remote func add_player_entity(id):
	var instance = load("res://entities/ServerEntity.tscn").instance()
#	instance.set_script(EntityMovement)
	instance.global_transform.origin = Vector3(0,5,0)
	instance.set_name(str(id))
	print("added character model")
	map.add_child(instance)
	players[id] = instance
	player_id_relations[id] = get_tree().get_rpc_sender_id()
	
remote func remove_player_entity(id):
	var node = map.get_node(str(id))
	map.remove_child(node)
	if node != null:
		node.call_deferred("free")
		
remote func add_dest(id,loc,type):
	var player = map.get_node(str(id))
	if player != null:
		player.add_dest(loc,type)

func server_set_player_dest(id,dest):
	var rid = player_id_relations[id]
	rpc_unreliable_id(rid,"client_set_player_dest",dest)
remote func client_set_player_dest(dest:Array):
	map.get_node("P1").get_node("Player").dest = dest
	
remote func toggle_autopilot(id):
	var player = map.get_node(str(id))
	if player != null:
		player.toggle_autopilot()

remote func get_player_postion(id) -> Vector3:
	return players[id].rigid.global_transform.origin
remote func get_player_basis(id) -> Dictionary:
	var player = players[id].rigid
	var basis = player.global_transform.basis
	return {"x":basis.x,"y":basis.y,"z":basis.z}
	
func _on_startserver_toggled(button_pressed):
	if button_pressed:
		create_server()
	else:
		server = null
