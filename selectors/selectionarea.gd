extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = "Waypoint"
func in_transit(player:Object):
	pass
func at_dest(player:Object):
	player.rigid.global_transform.origin = self.global_transform.origin
