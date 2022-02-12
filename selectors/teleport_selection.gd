extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "Teleport"


func in_transit(player:Object):
	player.rigid.global_transform.origin = player.dest[0]
	player.rigid.angular_velocity = Vector3()
	
func at_dest(player:Object):
	player.rigid.global_transform.origin = self.global_transform.origin
