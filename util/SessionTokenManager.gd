extends Node

onready var verified_session_tokens = {}


func verify_session_token(publickey,token,retryCount = 0) -> bool:
	print("checkingf")
	if verified_session_tokens.has(publickey):
		print("has")
		return (verified_session_tokens.get(publickey) == token)
	else:
		return false
			
remote func initialize_session_token(publickey,token):
	http_query_session_token(publickey,token)
	
func http_query_session_token(publickey,token):
	var query = JSON.print({"publickey":publickey,"token":token})
	$HTTPRequest.request(HttpServerManager.url + "/verify_session",HttpServerManager.headers,HttpServerManager.use_ssl,HTTPClient.METHOD_POST,query)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var res = body.get_string_from_utf8()
	var json = res.to_json()
	print("json" + json)
	if bool(json.valid):
		verified_session_tokens[json.publickey] = true
