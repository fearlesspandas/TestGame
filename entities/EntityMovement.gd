extends Node
export var accell : float = 2.5
var decell : float = accell
export var jumpForce :float = 15
export var gravity : float = 40
export var MAX_MOVE_SPEED = 10
export var path_finding_epsiolon : float = 1
var accelerating:bool = false
var allowed_to_move:bool = true
var dest : Array = []
var next_dest :Vector3 = Vector3()
var path : Vector3 = Vector3()
var moveSpeed_x : float = 0
var moveSpeed_z : float = 0
var autopilot_on: bool = true
onready var rigid = get_node("RigidBody")
onready var main_map = find_parent("Main")

func add_dest(loc,type):
	dest.append({"type":type,"location":loc})
#func remove_dest(loc,)
func decelerate(value:float) -> float:
	if value > 0:
		value -= min(decell,value) 
	if value < 0:
		value += min(decell,-value)
	return value
	
func capspeed(value:float) -> float:
	if value > MAX_MOVE_SPEED:
		return MAX_MOVE_SPEED
	elif value < -MAX_MOVE_SPEED:
		return -MAX_MOVE_SPEED
	else:
		return value

func toggle_autopilot():
	autopilot_on = not autopilot_on
func handle_movement_speeds(within_epsilon:bool,input:Vector3,delta):
	if within_epsilon:
		decelerate(moveSpeed_z)
		decelerate(moveSpeed_x)
	else:
		moveSpeed_z += accell * input.z * delta
		moveSpeed_x += accell * input.x * delta
		moveSpeed_x = capspeed(moveSpeed_x)
		moveSpeed_z = capspeed(moveSpeed_z)
	
func handle_autopilot(delta):
	if dest.size() > 0:
		var next_dest = dest[0]
		var next = next_dest.location
		var diff_vec = rigid.global_transform.origin - next
		var within_epsilon = diff_vec.length() < path_finding_epsiolon
		handle_movement_speeds(within_epsilon,Vector3(1,1,1),delta)
		if within_epsilon:
			dest.pop_front()
		else:
			rigid.set_axis_velocity(diff_vec.normalized() * moveSpeed_z)
#func handle_manual(dir:Vector3):

func _physics_process(delta):
	if autopilot_on:
		handle_autopilot(delta)
