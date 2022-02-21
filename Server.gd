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
var spawn_loc = Vector3(0,3,0)
var player_input_queue = []
var player_id:String = "Player"
var client_entities = {}
var client_session_id = ""
onready var server_map = load("res://world_models/Blockofthing.tscn")
onready var client_map = load("res://ClientMap.tscn")
var lobby_instance = null
var map

func _ready():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168"):
			ip_address = ip
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	
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

func kicked():
	rpc("remove_player_entity",player_id)
	rpc("decrease_connected")
	get_tree().network_peer = null	
	get_tree().get_root().get_child(0).remove_child(map)
	OS.set_window_fullscreen(false)
#	lobby_instance.visible = true
	
	
func _server_disconnected() -> void:
	rpc("remove_player_entity",player_id)
	rpc("decrease_connected")
	print("disconnected from server")	
	
	
func add_player_client_model():
	var instance = load("res://ClientMarble.tscn").instance()
#	instance.set_script(ClientPlayerMovement)
	instance.global_transform.origin = spawn_loc
	instance.set_name("P1")
	map.add_child(instance)
	
	
remote func client_set_entity_player_pos(loc,rot,id):
	if id != player_id:
		var entity = client_entities[id]
		if entity != null:
			entity.last_known_position = loc
			entity.kinematic.rotation_degrees = rot
remote func server_set_entity_player_pos2(entityid,loc,rot):
	rpc_unreliable("client_set_entity_player_pos",loc,rot,entityid)
remote func server_set_entity_player_pos(entityid,pid)	:
	if get_tree().is_network_server() and players.has(entityid):
		var rid = player_id_relations[pid]
		var entity = players[entityid]
		var loc = entity.global_transform.origin
		var rot = entity.rotation_degrees
		rpc_unreliable_id(rid,"client_set_entity_player_pos",loc,rot,entityid)
func client_call_server_set_entity(entityid,pid):
	rpc_unreliable("server_set_entity_player_pos",entityid,pid)
	
	
remote func set_client_player_pos(loc:Vector3,rot):
	map.get_node("P1").get_node("Player").move_towards_loc(loc,rot)
	
remote func set_client_rotation_deg(rot):
	map.get_node("P1").get_node("Player").set_rotation_degrees(rot)
	
remote func set_client_player_basis(basis:Basis):
	map.get_node("P1").get_node("Player").rigid.global_transform.basis = basis
	
func server_set_client_rotation_deg(id,rot):
	if get_tree().is_network_server():
		var rid = player_id_relations[id]
		rpc_unreliable_id(rid,"set_client_rotation_deg",rot)
	
func server_set_client_player_pos(id,loc,rot):
	if get_tree().is_network_server():
		var rid = player_id_relations[id]
		rpc_unreliable_id(rid,"set_client_player_pos",loc,rot)
	
func server_set_client_player_basis(id,basis:Basis):
	if get_tree().is_network_server():
		var rid = player_id_relations[id]
		rpc_unreliable_id(rid,"set_client_player_basis",basis)
	
func client_add_dest(id,loc,type):
	rpc("add_dest",id,loc,type)
	
func client_move_entity(path:Vector3,id):
	rpc_unreliable("server_move_entity",path,id)
	
remote func server_move_entity(path:Vector3,id):
	if get_tree().is_network_server():
		players[id].handle_dir(path)
	
remotesync func increase_connected():
	connected_clients += 1
	
remotesync func decrease_connected():
	connected_clients -= 1
	
remote func record_player_input(id,input,type):
	player_input_queue.append({"id":id,"input":input,"type":type})
	
remote func client_add_entity(id):
	var instance = load("res://entities/ClientEntity.tscn").instance()
	instance.player_id = id
	instance.set_name(str(player_id))
	map.add_child(instance)
	client_entities[id] = instance
func server_broadcast_players(to_id):
	var rid = player_id_relations[to_id]
	for p_k in players.keys():
		if p_k != to_id:
			rpc_id(rid,"client_add_entity",p_k)	
func server_broadcast_new_entity(id):
	for p_k in players.keys():
		if p_k != id:
			var rid = player_id_relations[p_k]
			rpc_id(rid,"client_add_entity",id)
		
remote func add_player_entity(id):
	if get_tree().is_network_server():
		var instance = load("res://entities/ServerEntity.tscn").instance()
	#	instance.set_script(EntityMovement)
		instance.global_transform.origin = spawn_loc
		instance.set_name(str(id))
		print("added character model")
		map.add_child(instance)
		players[id] = instance
		player_id_relations[id] = get_tree().get_rpc_sender_id()
		server_broadcast_new_entity(id)
		server_broadcast_players(id)
	
remote func remove_player_entity(id):
	print("removing player model")
	players.erase(id)
	player_id_relations.erase(id)
	var node = map.get_node(str(id))
	map.remove_child(node)
	if node != null:
		node.call_deferred("free")
		
remote func add_dest(id,loc,type):
	if get_tree().is_network_server():
		var player = map.get_node(str(id))
		if player != null:
			player.add_dest(loc,type)
	
func server_set_player_dest(id,dest):
	if get_tree().is_network_server():
		var rid = player_id_relations[id]
		rpc_unreliable_id(rid,"client_set_player_dest",dest)
remote func client_set_player_dest(dest:Array):
	map.get_node("P1").get_node("Player").dest = dest
	map.get_node("P1").get_node("Player").draw_dest()
func client_toggle_autopilot():
	rpc("toggle_autopilot",Server.player_id)
remote func toggle_autopilot(id):
	if  get_tree().is_network_server():
		var player = players[id]
		if player != null :
			player.toggle_autopilot()
func client_clear_waypoints():
	rpc("server_clear_waypoints",Server.player_id)
remote func server_clear_waypoints(id):
	if get_tree().is_network_server():
		players[id].dest = []
		Server.server_set_player_dest(id,[])
	
func _on_startserver_toggled(button_pressed):
	if button_pressed:
		create_server()
	else:
		server = null
