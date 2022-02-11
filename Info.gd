extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var new_account_selector:CheckButton = find_node("NewAccount")
onready var username_input:TextEdit = find_node("username")
onready var password_input:TextEdit = find_node("password")
export var host = "http://localhost:8090"
export var headers = ["Content-Type: application/json"]
var cert
func login(username,password):
	var payload = JSON.print({"publicKey":password})
	$HTTPRequest.request(host + "/login", headers, true, HTTPClient.METHOD_POST, payload)
	pass
	

func sign_up(username,password):
	var crypto = Crypto.new()
	var key = crypto.generate_rsa(4096)
	var k = key
	var public_key = key.load_from_string(k.save_to_string(true),true)
	var payload = JSON.print({"username":username,"password":public_key})
	cert = crypto.generate_self_signed_certificate(k, "CN=example.com,O=A Game Company,C=IT")
	$HTTPRequest.request(host + "/signup", headers, true, HTTPClient.METHOD_POST, payload)
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	$HTTPRequest.request("http://localhost:8090/player/0")

#func _process(delta):
	



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	#info.text = body.get_string_from_utf8()

func _on_Button_toggled(button_pressed):
	if button_pressed and new_account_selector.toggle_mode:
		sign_up(username_input.text,password_input.text)
	if button_pressed and not new_account_selector.toggle_mode:
		login(username_input.text,password_input.text)
#		$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
#	pass
