extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("Player")
onready var rigidplayer = player.get_node("RigidBody")
onready var cameraorbit = get_node("PlayerCam")
onready var camera = get_node("PlayerCam/cameraorbit/CameraBody/Camera")

var thresh : float = 1
func _physics_process(delta):
	var playerloc = rigidplayer.global_transform.origin
	var cameraloc = cameraorbit.global_transform.origin
	var avg_speed = sqrt(player.moveSpeed_x * player.moveSpeed_x + player.moveSpeed_z * player.moveSpeed_z)
	var diff = cameraloc - playerloc
	diff = (diff).normalized() * delta * max (avg_speed,diff.length()) 
	
#	if diff.x/delta < thresh:
#		diff.x = 0
#	if diff.z/delta < thresh:
#		diff.z = 0
	if not cameraorbit.detached:
		cameraorbit.global_transform.origin = playerloc
#		cameraorbit.global_transform.origin.x -= diff.x
#		cameraorbit.global_transform.origin.z -= diff.z
#		cameraorbit.global_transform.origin.y -= diff.y
	
		
