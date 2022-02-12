extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("Player")
onready var rigidplayer = player.get_node("KinematicBody")
onready var cameraorbit = get_node("PlayerCam")
onready var camera = get_node("PlayerCam/cameraorbit/CameraBody/Camera")
#export(String) var playermovement
var thresh : float = 1

#func _ready():
#	var s = load(playermovement)
#	player.set_script(s)
#	player.force_update_transform()
func _physics_process(delta):
	var playerloc = rigidplayer.global_transform.origin
	var cameraloc = cameraorbit.global_transform.origin
	var diff = cameraloc - playerloc
	diff = (diff).normalized() * delta * diff.length() 

	if not cameraorbit.detached:
		cameraorbit.global_transform.origin = playerloc
#		cameraorbit.global_transform.origin.x -= diff.x
#		cameraorbit.global_transform.origin.z -= diff.z
#		cameraorbit.global_transform.origin.y -= diff.y
	
		
