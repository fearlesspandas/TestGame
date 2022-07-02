extends Node


var map

func _ready():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168"):
			ServerManager.ip_address = ip
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("server_disconnected",self,"_server_disconnected")
	

#server
func create_server() -> void:
	print("creating server")
	ServerManager.server = NetworkedMultiplayerENet.new()
	ServerManager.server.create_server(ServerManager.port,ServerManager.maxclients)
	get_tree().set_network_peer(ServerManager.server)
	map = WorldModelResourceManager.ServerMap.instance()
	map.set_name("Map")
	map.global_transform.origin = Vector3()
	add_child(map)
#client	
func join_server() -> void:
	ClientManager.client = NetworkedMultiplayerENet.new()
	ClientManager.client.create_client(ClientManager.ip_address,ClientManager.port)
	get_tree().set_network_peer(ClientManager.client)
#client	
func _connected_to_server() -> void:
	rpc("increase_connected")
	rpc("add_player_entity",ClientManager.player_id,ClientManager.username)
	map = WorldModelResourceManager.ClientMap.instance()
	map.set_name("Map")
	map.global_transform.origin = Vector3()
	add_player_client_model()
	add_child(map)
	print("successfully connected")
#Client
func kicked():
	rpc("remove_player_entity",ClientManager.player_id)
	rpc("decrease_connected")
	get_tree().network_peer = null	
	get_tree().get_root().get_child(0).remove_child(map)
	OS.set_window_fullscreen(false)
#Client		
func _server_disconnected() -> void:
	rpc("remove_player_entity",ClientManager.player_id)
	rpc("decrease_connected")
	print("disconnected from server")	
	
#Client	
func add_player_client_model():
	if ClientManager.player_instance == null:
		print("adding player client model")
		var instance = EntityResourceManager.PlayerClientModel.instance()
		instance.global_transform.origin = ClientManager.spawn_loc
		instance.set_name("P1")
		var fields = {"instance":instance}
		ClientManager.entities[ClientManager.player_id] = fields
		map.add_child(instance)
	

#Client	
remote func set_client_fields(id,fields):
#	print("client received server response")
	if ClientManager.entities.has(id):
		var player = ClientManager.entities[id]["instance"]
		player.get_entity().update_fields(fields)
#Server
func server_set_client_fields_unreliable(id,fields):
	if get_tree().is_network_server() and ServerManager.players.has(id):
		rpc_unreliable("set_client_fields",id,fields)
		
func server_set_client_fields(id,fields):
	if get_tree().is_network_server() and ServerManager.players.has(id):
		rpc("set_client_fields",id,fields)		
#Client
func client_add_fields(id,fields):
	rpc("update_fields",id,fields)
func client_add_fields_unreliable(id,fields):
	rpc_unreliable("update_fields",id,fields)

#Server	
remotesync func increase_connected():
	ServerManager.connected_clients += 1
#Server	
remotesync func decrease_connected():
	ServerManager.connected_clients -= 1
#Client	
remote func client_add_entity(id):
	print("adding entity",id,ClientManager.player_id)
	if id != ClientManager.player_id:
		var instance = EntityResourceManager.ClientEntity.instance()
		instance.player_id = id
		instance.set_name(str(id))
		map.add_child(instance)
		ClientManager.entities[id] = {"instance":instance}
#Server
#broadcasts connected players
#to newly connected client
func server_broadcast_players(to_id):
	var rid = ServerManager.players[to_id]["rpc_id"]
	for p_k in ServerManager.players.keys():
		if p_k != to_id:
			rpc_id(rid,"client_add_entity",p_k)	
#Server
#broadcasts a newly connected player
#to all other currently connected players
func server_broadcast_new_entity(id):
	for p_k in ServerManager.players.keys():
		if p_k != id:
			var rid = ServerManager.players[p_k]["rpc_id"]
			rpc_id(rid,"client_add_entity",id)
#Server		
remote func add_player_entity(id,username):
	#todo - add check against http server session
	#to ensure this cant be exploited
	if get_tree().is_network_server() and not ServerManager.players.has(id):
		var instance = EntityResourceManager.ServerPlayerModel.instance()
	#	instance.set_script(EntityMovement)
		instance.global_transform.origin = ServerManager.spawn_loc
		instance.set_name(str(id))
		print("added character model")
		var fields = {"instance":instance,"rpc_id":get_tree().get_rpc_sender_id(),"username":username}
		map.add_child(instance)
		ServerManager.players[id] = fields
		server_broadcast_new_entity(id)
		server_broadcast_players(id)
#Server	
remote func remove_player_entity(id):
	print("removing player model")
	ServerManager.players.erase(id)
	var node = map.get_node(str(id))
	map.remove_child(node)
	if node != null:
		node.call_deferred("free")
#Server		
remote func update_fields(id,fields):
#	print("updating fields", str(fields))
	if get_tree().is_network_server():
		var player = map.get_node(str(id))
		if player != null:
			player.update_fields(fields)



#utility functions need to abstract
#client
func client_toggle_autopilot():
	rpc("toggle_autopilot",ClientManager.player_id)
#server
remote func toggle_autopilot(id):
	if  get_tree().is_network_server():
		var player = ServerManager.players[id]
		if player != null :
			player.toggle_autopilot()
#client
func client_clear_waypoints():
	rpc("server_clear_waypoints",ClientManager.player_id)
#server
remote func server_clear_waypoints(id):
	if get_tree().is_network_server():
		ServerManager.players[id].dest = []
		server_set_client_fields(id,{"dest":[]})
#client and server
func _on_startserver_toggled(button_pressed):
	if button_pressed:
		create_server()
	else:
		ServerManager.server = null
