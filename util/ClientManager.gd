extends Node


#Server variables
var ip_address = ""
var port = 8090

#Client Variables
onready var spawn_loc = Vector3(0,10,0)
var client = null
var player_id:String = "Player"
var entities = {}
var player_instance = null
var username = ""
func _ready():
	pass # Replace with function body.
