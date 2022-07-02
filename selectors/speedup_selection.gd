extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "SpeedUp"


func in_transit(player:Object):
	player.MAX_MOVE_SPEED = player.MAX_MOVE_SPEED * 2
	
func at_dest(player:Object):
#	player.rigid.global_transform.origin = self.global_transform.origin
#	player.rigid.angular_velocity = Vector3()
	null
