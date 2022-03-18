extends Control

var username:String = ""
var public_key: String = ""
var private_key:String = ""
onready var host = HttpServerManager.host
onready var port = HttpServerManager.port
onready var url = HttpServerManager.url
onready var username_label = find_node("username")
onready var info = find_node("info")
onready var session_token_manager = find_node("SessionTokenManager")
onready var ip_label = find_node("ip_label")
func _process(delta):
	username_label.text = username
#	public_key_label.text = public_key

func _make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)

func create_session():
	_make_post_request(url + "/create_session",public_key,false)

func _on_Button_pressed():
	create_session()


func _on_copy_public_key_pressed():
	OS.clipboard = public_key


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
#	print("pk",private_key)
#	print("result",body.get_string_from_utf8())

	var json = body.get_string_from_utf8()
	if json != null:
		var crypto = Crypto.new()
		var pvkey = CryptoKey.new()
		var pbkey = CryptoKey.new()
		pvkey.load_from_string(private_key)
		
		pbkey.load_from_string(public_key)
		var encd = crypto.encrypt(pvkey,"testing".to_utf8())
		var bodyraw = Marshalls.base64_to_raw(body.get_string_from_utf8())
		var decrypted = crypto.decrypt(pvkey,bodyraw)
		if not decrypted.empty():
			var sess_tok = Marshalls.base64_to_utf8(Marshalls.raw_to_base64(decrypted))
			HttpServerManager.client_session_id = sess_tok
			info.text = "New Session Id added: " + HttpServerManager.client_session_id
			ClientManager.player_id = HttpServerManager.client_session_id
			ClientManager.username = username
			ClientManager.ip_address = ip_label.text
			NetworkManager.join_server()
			self.get_parent().visible = false

func _on_Button2_pressed():
	info.text = str(session_token_manager.verify_session_token(public_key,HttpServerManager.client_session_id))
