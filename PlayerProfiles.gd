extends TabContainer

export(Resource) var PlayerProfile
export(Resource) var CreateUser
export(Resource) var createServer
onready var session_token_manager = find_node("SessionTokenManager")
var profiles = []

func remove_recursive(path):
	var directory = Directory.new()
	
	# Open directory
	var error = directory.open(path)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)
func add_player_profile(username,pubkey,private_key):	
	var instance = PlayerProfile.instance()
	instance.username = username
	instance.public_key = pubkey
	instance.private_key = private_key
	instance.set_name(username)
	self.add_child(instance)
func _ready():
	var dir = Directory.new()
	var dir_open = dir.open("user://")
	if dir_open == OK:
		var ls_dir = dir.list_dir_begin()
		if ls_dir == OK:
			var file = dir.get_next()
			while file != "":
				if file.find("_profile") > -1:
					profiles.append(file)
				file = dir.get_next()
		#add user profiles
		for p in profiles:
			var profile_path = "user://" + p
			var username = str(p).replace("_profile","")
			var pk_file = File.new()
			var pub_open = pk_file.open(profile_path + "/public.key",File.READ)
			var pv_file = File.new()
			var priv_open = pv_file.open(profile_path + "/private.key",File.READ)
			if pub_open == OK and priv_open == OK:
				var instance = PlayerProfile.instance()
				instance.username = username
				instance.public_key = pk_file.get_as_text()
				instance.private_key = pv_file.get_as_text()
				pk_file.close()
				pv_file.close()
				instance.set_name(username)
				self.add_child(instance)
		#add new user
		var create_user_instance = CreateUser.instance()
		create_user_instance.set_name("+")
#		var create_server_instance = createServer.instance()
#		createServer.set_name("new_server")
		self.add_child(create_user_instance)
#		self.add_child(createServer)
