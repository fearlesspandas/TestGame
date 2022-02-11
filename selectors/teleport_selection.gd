extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = find_parent("Main").find_node("Player")

func in_transit(player:Object):
	if player.within_epsilon and player.next_sel == self:
		player.rigid.global_transform.origin = player.dest[0]
		player.rigid.angular_velocity = Vector3()
#	print(player.global_transform.origin,player.dest)
	
func at_dest(player:Object):
	if Input.is_action_just_pressed("click"):
		player.dest.pop_front()
		player.selection.pop_front()
		player.selections_for_removal.push_back(self)
		player.next_sel = null
		player.destroy_selections()

func _on_Area_mouse_entered():
	player.stop_selection = true
	print("entered selection")
	if Input.is_action_just_pressed("click") or not player.autopilot_on:
		var ind = player.selection.find(self)
		player.selections_for_removal.push_back(player.selection[ind])
		player.selection.remove(ind)
		player.dest.remove(ind)
		player.destroy_selections()

