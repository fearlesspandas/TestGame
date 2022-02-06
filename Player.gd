extends Spatial
export var accell : float = 2.5
var decell : float = accell
export var jumpForce :float = 15
export var gravity : float = 40
export var MAX_MOVE_SPEED = 10
export var path_finding_epsiolon : float = 1
var accelerating:bool = false
var dest : Array = []
var next_dest :Vector3 = Vector3()
var path : Vector3 = Vector3()
var moveSpeed_x : float = 0
var moveSpeed_z : float = 0
var selection:Array = []
var next_sel: Node = null
var selections_for_removal: Array = []
var within_epsilon : bool = false
var active_dest : bool = false
onready var rigid = get_node("RigidBody")
onready var camera = get_parent().get_node("PlayerCam")
onready var camerautil:Camera = camera.get_node("Camera")
onready var cursor_ray = camera.get_node("CameraSpace/CameraBody/Camera/CursorRay")
func decelerate(value:float) -> float:
	if value > 0:
		value -= min(decell,value) 
	if value < 0:
		value += min(decell,-value)
	return value
#func accellerate(value:float,idle:bool,accelleration:float) -> float:
#	if not idle
func getInput() -> Vector3:
	var input:Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		input.z += 1
	if Input.is_action_pressed("move_backward"):
		input.z -= 1
	if Input.is_action_pressed("move_left"):
		input.x += 1
	if Input.is_action_pressed("move_right"):
		input.x -= 1
	if Input.is_action_just_pressed("jump") and not camera.detached:
		input.y += 1
	input = input.normalized()
	return input
func capspeed(value:float) -> float:
	if value > MAX_MOVE_SPEED:
		return MAX_MOVE_SPEED
	elif value < -MAX_MOVE_SPEED:
		return -MAX_MOVE_SPEED
	else:
		return value
func create_selection():
	var instance = load("res://selectionarea.tscn").instance()
	get_tree().get_root().get_child(0).add_child(instance)
	selection.push_back(instance)
	instance.global_transform.origin = cursor_ray.intersect_pos
func destroy_selections():
	for s in selections_for_removal:
		get_tree().get_root().get_child(0).remove_child(s)
		if s != null:
			s.call_deferred("free")
	selections_for_removal = []
func handle_left_click():
	if Input.is_action_just_released("click"):
		dest.push_back(cursor_ray.intersect_pos)
#		rigid.set_axis_velocity(path * -1)
#		moveSpeed_z = 0
#		remove_child(selection)
#		if(selection.size() == 0):
#			selections_for_removal.push_back(next_sel)
#			destroy_selections()
		create_selection()
		
		
func _physics_process(delta):
	var input = getInput()
	var diff = Vector3()
	handle_left_click()
	active_dest = dest.size() > 0
	if active_dest:
		next_dest = dest[0]
		diff = (next_dest - rigid.global_transform.origin)
		within_epsilon = diff.length() < path_finding_epsiolon
	
	accelerating =  (active_dest and not within_epsilon)
	
	if accelerating:
		moveSpeed_z += delta*accell
	else:
		moveSpeed_x = decelerate(moveSpeed_x)
		moveSpeed_z = decelerate(moveSpeed_z)
	moveSpeed_x = capspeed(moveSpeed_x)
	moveSpeed_z = capspeed(moveSpeed_z)
	var checkforzero = moveSpeed_z
	if checkforzero == 0:
		checkforzero = 1
	
	path = (diff.normalized() * checkforzero) + Vector3(0,input.y* jumpForce,0)
	if (accelerating) or input.y > 0:
		
		rigid.set_axis_velocity(path)
	
#	dest = Vector3()
	if within_epsilon and selection.size() > 0:
		dest.pop_front()
		next_sel = selection.pop_front()
		selections_for_removal.push_back(next_sel)
		destroy_selections()
	if within_epsilon and selection.size ()== 0:
		rigid.global_transform.origin = next_dest
		rigid.angular_velocity = Vector3()
		selections_for_removal.push_back(next_sel)
		next_sel = null
		destroy_selections()
			
	print(selection.size())

