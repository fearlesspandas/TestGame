extends Node


const port = 8090
const maxclients = 100
var server = null
var players = {}
var player_id_relations = {}
var player_username_relations = {}
var ip_address = ""
var connected_clients = 0
onready var spawn_loc = Vector3(0,10,0)
onready var verified_session_tokens = {}
onready var server_manager_obj = load("res://util/ServerManager.tscn").instance()
onready var HttpReq:HTTPRequest = server_manager_obj.find_node("HttpRequest")

func _ready():
	pass # Replace with function body.
func verify_session_token(publickey,token,retryCount = 0) -> bool:
	if verified_session_tokens.has(publickey):
		return (verified_session_tokens.get(publickey) == token)
	else:
		if retryCount < 5:
			http_query_session_token(publickey,token)
			return verify_session_token(publickey,token, retryCount + 1)
		else:
			return false
func http_query_session_token(publickey,token):
	var query = JSON.print({"publickey":publickey,"token":token})
	HttpReq.request(HttpServerManager.url + "/verify_session",HttpServerManager.headers,HttpServerManager.use_ssl,HTTPClient.METHOD_POST)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var res = body.get_string_from_utf8()
	var json = res.to_json()
	if bool(json.valid):
		verified_session_tokens[json.publickey] = true
