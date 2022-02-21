extends Control


var crypto = Crypto.new()
var key = CryptoKey.new()
var cert = X509Certificate.new()

onready var new_key_label = find_node("new_key")
onready var info_label = find_node("info_label")
onready var username = find_node("username_in")
onready var import_menu :MenuButton= find_node("ImportMenu")
onready var user_list : ItemList = find_node("UserList")
onready var tabs = find_parent("TabContainer")
var protocol = "http"
var host = "localhost"
var port = "8080"
var url_base = protocol + "://" + host + ":" + port
func get_players_url(lim:int,start:int) -> String:
	return url_base + "/players?lim=" + str(lim) + "&start=" + str(start)
func _make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)

func _process(delta):
	#add 10 
	pass
func check_username_exists(input:String) -> bool:
	return false
func _on_generate_key_pressed():
	key = crypto.generate_rsa(4096)
	cert = crypto.generate_self_signed_certificate(key, "CN=deeperbeings.com,O=Deeper Beings,C=IT")
	var pkey = key.save_to_string()
	
	info_label.text = "Your key pair has been saved, but copying a backup is always a good idea"
	var new_user_dir = "user://" + username.text + "_profile"
	if not check_username_exists(username.text):
		var dir = Directory.new()
		var new_dir_made = dir.make_dir(new_user_dir)
		if new_dir_made == OK:
			print(dir.open(new_user_dir))
			var keysaved = key.save(new_user_dir + "/private.key")
			var pubkeysaved = key.save(new_user_dir + "/public.key",true)
			var certsaved = cert.save(new_user_dir + "/generated.crt")
			if keysaved == OK and pubkeysaved == OK and certsaved == OK:
				new_key_label.text = pkey
				new_key_label.visible = true
				tabs.add_player_profile(username.text,key.save_to_string(true),key.save_to_string())
			else:
				info_label.text = "an error occurred while trying to save your key pair"
		else:
			info_label.text = "profile folder could not be made, make sure the username is not used by another profile"
	else:
		info_label.text = "username already exists"


func _on_ImportMenu_about_to_show():
	import_menu.get_popup().add_item("Landon")
