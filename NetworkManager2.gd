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
		ClientManager.player_instance = instance
		map.add_child(ClientManager.player_instance)
	
#client	
remote func client_set_entity_non_player_pos(loc,rot,id):
#	print("id",id)

	if id != ClientManager.player_id:
		if ClientManager.client_entities.has(id):
#			print("client set other player pos: " + str(loc))
			var entity = ClientManager.client_entities[id]
			entity.last_known_position = loc
			entity.kinematic.rotation_degrees = rot
#Server
remote func server_set_entity_non_player_pos(entityid,loc,rot):
	rpc_unreliable("client_set_entity_non_player_pos",loc,rot,ServerManager.player_username_relations[entityid])
#Server
remote func server_set_entity_player_pos(entityid,pid)	:
	if get_tree().is_network_server() and ServerManager.players.has(entityid):
		var rid = ServerManager.player_id_relations[pid]
		var entity = ServerManager.players[entityid]
		var loc = entity.global_transform.origin
		var rot = entity.rotation_degrees
		rpc_unreliable_id(rid,"client_set_entity_player_pos",loc,rot,entityid)
		
remote func server_set_npc_properties(npcid,properties):
	rpc_unreliable("client_set_npc_properties",properties)
func client_set_npc_properties(npcid,properties):
	if ClientManager.client_entities.has(npcid):
		var npc = ClientManager.client_entities[npcid]
		npc.properties = properties

#Client	
remote func set_client_player_pos(loc:Vector3,rot,jump_force):
#	print("client received server response")
	var player = ClientManager.player_instance.get_node("Player")
	player.move_towards_loc(loc,rot)
	player.jump_force = jump_force
#Server
func server_set_client_player_pos(id,loc,rot,jump_force):
#	print(ServerManager.players)
#	print(id)
	if get_tree().is_network_server() and ServerManager.player_id_relations.has(id):
#		print("server client response")
		var rid = ServerManager.player_id_relations[id]
		rpc_unreliable_id(rid,"set_client_player_pos",loc,rot,jump_force)
#Client
func client_add_dest(id,loc,type):
	rpc("add_dest",id,loc,type)
#Client	
func client_move_entity(path:Vector3,id):
#	print("network man moving client")
	rpc_unreliable("server_move_entity",path,id)
#Server	
remote func server_move_entity(path:Vector3,id):
	if get_tree().is_network_server():
#		print("network man moving server")
		ServerManager.players[id].handle_dir(path)
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
		ClientManager.client_entities[id] = instance
#Server
#broadcasts connected players
#to newly connected client
func server_broadcast_players(to_id):
	var rid = ServerManager.player_id_relations[to_id]
	for p_k in ServerManager.players.keys():
		if p_k != to_id:
			rpc_id(rid,"client_add_entity",ServerManager.player_username_relations[p_k])	
#Server
#broadcasts a newly connected player
#to all other currently connected players
func server_broadcast_new_entity(id):
	for p_k in ServerManager.players.keys():
		if p_k != id:
			var rid = ServerManager.player_id_relations[p_k]
			rpc_id(rid,"client_add_entity",ServerManager.player_username_relations[id])
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
		map.add_child(instance)
		ServerManager.players[id] = instance
		ServerManager.player_id_relations[id] = get_tree().get_rpc_sender_id()
		ServerManager.player_username_relations[id]  = username
		server_broadcast_new_entity(id)
		server_broadcast_players(id)
#Server	
remote func remove_player_entity(id):
	print("removing player model")
	ServerManager.players.erase(id)
	ServerManager.player_id_relations.erase(id)
	var node = map.get_node(str(id))
	map.remove_child(node)
	if node != null:
		node.call_deferred("free")
#Server		
remote func add_dest(id,loc,type):
	if get_tree().is_network_server():
		var player = map.get_node(str(id))
		if player != null:
			player.add_dest(loc,type)
#Server
func server_set_player_dest(id,dest):
	if get_tree().is_network_server():
		var rid = ServerManager.player_id_relations[id]
		rpc_unreliable_id(rid,"client_set_player_dest",dest)
#client
remote func client_set_player_dest(dest:Array):
	ClientManager.player_instance.get_node("Player").dest = dest
	ClientManager.player_instance.get_node("Player").draw_dest()
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
		server_set_player_dest(id,[])
#client and server
func _on_startserver_toggled(button_pressed):
	if button_pressed:
		create_server()
	else:
		ServerManager.server = null
