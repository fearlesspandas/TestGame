extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func in_transit(player:Object):
#	player.dest.pop_front()
#	player.selections_for_removal.push_back(self)
#	player.selection.pop_front()
#	#handle selection transit
#	player.destroy_selections()
	pass
func at_dest(player:Object):
#	player.rigid.global_transform.origin = player.next_dest
#	player.rigid.angular_velocity = Vector3()
	if Input.is_action_just_pressed("click"):
		player.selections_for_removal.push_back(self)
		player.next_sel = null
		player.dest.pop_front()
		player.selection.pop_front()
		player.destroy_selections()
