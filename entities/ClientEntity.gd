extends Spatial

var protocol = "http"
var domain = "localhost"
var port = "8080"
var query = "pos"

var player_id = ""
var last_known_position = null
onready var kinematic = find_node("KinematicBody")
func get_position_from_server():
	if player_id != null and player_id.length() > 0:
		Server.client_call_server_set_entity(player_id,Server.player_id)
func set_rotation_degrees(rot):
	kinematic.rotation_degrees = rot
func handle_position():
	if last_known_position != null:
		kinematic.global_transform.origin = last_known_position
		last_known_position = null
func _physics_process(delta):
	get_position_from_server()
	handle_position()
